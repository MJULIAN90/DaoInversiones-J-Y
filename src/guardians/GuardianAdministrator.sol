// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// =============================================================
//                           IMPORTS
// =============================================================

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IGuardianBondEscrow} from "../interfaces/IGuardianBondEscrow.sol";

// =============================================================
//                          CONTRACTS
// =============================================================

/// @title GuardianAdministrator
/// @author Julian Ruiz
/// @notice Manages guardian applications, approvals, resignations, and bans
/// @dev Handles bond escrow, governance proposal flow, and guardian lifecycle
contract GuardianAdministrator {
  /*//////////////////////////////////////////////////////////////
                          TYPE DECLARATIONS
  //////////////////////////////////////////////////////////////*/

  using Strings for address;
  using Strings for uint256;

  /// @notice Guardian status states
  enum Status {
    Inactive,
    Pending,
    Active,
    Rejected,
    Resigned,
    Banned
  }

  /// @notice Guardian details structure
  struct GuardianDetail {
    Status status;
    uint256 balance;
    uint256 blockRequest;
    uint256 proposalId;
  }

  /*//////////////////////////////////////////////////////////////
                            STATE
  //////////////////////////////////////////////////////////////*/

  /// @notice Minimum stake amount required to become a guardian
  uint256 public minStake;

  /// @notice Token used for bonding/staking
  IERC20 public immutable bondingToken;

  /// @notice Governor contract for guardian approvals
  IGovernor public immutable governor;

  /// @notice Escrow contract that locks, refunds, releases, or slashes guardian bonds
  IGuardianBondEscrow public immutable bondEscrow;

  /// @notice Timelock contract authorized to execute privileged actions
  address public immutable timelock;

  /// @notice Mapping of guardian addresses to their details
  mapping(address => GuardianDetail) private guardians;

  /*//////////////////////////////////////////////////////////////
                            EVENTS
  //////////////////////////////////////////////////////////////*/

  event GuardianApplied(address indexed guardian, uint256 indexed proposalId);
  event GuardianApproved(address indexed guardian);
  event GuardianRejected(address indexed guardian, uint256 stakeRefunded);
  event GuardianResigned(address indexed guardian, uint256 stakeRefunded);
  event GuardianBanned(address indexed guardian, uint256 stakeForfeit);
  event MinStakeUpdated(uint256 oldStake, uint256 newStake);

  /*//////////////////////////////////////////////////////////////
                            ERRORS
  //////////////////////////////////////////////////////////////*/

  error GuardianAdministrator__AlreadyApplied();
  error GuardianAdministrator__ZeroAddress();
  error GuardianAdministrator__GuardianNotFound();
  error GuardianAdministrator__InvalidStatus();
  error GuardianAdministrator__NoPendingApplication();
  error GuardianAdministrator__ProposalStillActive();
  error GuardianAdministrator__NotAuthorized();
  error GuardianAdministrator__InvalidStakeAmount();

  /*//////////////////////////////////////////////////////////////
                            MODIFIERS
  //////////////////////////////////////////////////////////////*/

  modifier onlyTimelock() {
    if (msg.sender != timelock) revert GuardianAdministrator__NotAuthorized();
    _;
  }

  /*//////////////////////////////////////////////////////////////
                          CONSTRUCTOR
  //////////////////////////////////////////////////////////////*/

  /// @notice Initializes the GuardianAdministrator contract
  /// @param bondingToken_ The ERC20 token used for guardian bonding
  /// @param governor_ The governor contract used to propose and resolve approvals
  /// @param bondEscrow_ The escrow contract that holds guardian stake
  /// @param timelock_ The timelock contract address
  /// @param minStake_ The minimum stake amount required
  constructor(
    IERC20 bondingToken_,
    IGovernor governor_,
    IGuardianBondEscrow bondEscrow_,
    address timelock_,
    uint256 minStake_
  ) {
    _requireNonZeroAddresses(
      address(bondingToken_),
      address(governor_),
      address(bondEscrow_),
      timelock_
    );

    if (minStake_ == 0) revert GuardianAdministrator__InvalidStakeAmount();

    bondingToken = bondingToken_;
    governor = governor_;
    bondEscrow = bondEscrow_;
    timelock = timelock_;
    minStake = minStake_;
  }

  /*//////////////////////////////////////////////////////////////
                            EXTERNAL
  //////////////////////////////////////////////////////////////*/

  /// @notice Allows a user to apply as a guardian by bonding tokens
  /// @dev Creates a governance proposal for guardian approval
  function applyGuardian() external {
    address sender = msg.sender;
    GuardianDetail storage guardianDetail = guardians[sender];

    if (guardianDetail.status != Status.Inactive) {
      revert GuardianAdministrator__AlreadyApplied();
    }

    guardianDetail.status = Status.Pending;
    guardianDetail.balance = minStake;
    guardianDetail.blockRequest = block.number;

    bondEscrow.lock(sender, minStake);

    address[] memory targets =  new address[](1);
    uint256[] memory values = new uint256[](1);
    bytes[] memory calldatas = new bytes[](1);

    targets[0] = address(this);
    values[0] = 0;
    calldatas[0] = abi.encodeCall(this.guardianApprove, (sender));

    string memory description = string.concat(
      "Guardian Application: ",
      sender.toHexString(),
      " block: ",
      block.number.toString()
    );

    uint256 proposalId = governor.propose(
      targets,
      values,
      calldatas,
      description
    );

    guardianDetail.proposalId = proposalId;

    emit GuardianApplied(sender, proposalId);
  }

  /// @notice Approves a guardian application after successful governance execution
  /// @param guardian The address of the guardian to approve
  function guardianApprove(address guardian) external onlyTimelock {
    _requireNonZeroAddress(guardian);

    GuardianDetail storage guardianDetail = guardians[guardian];

    if (guardianDetail.status != Status.Pending) {
      revert GuardianAdministrator__InvalidStatus();
    }

    guardianDetail.status = Status.Active;

    emit GuardianApproved(guardian);
  }

  /// @notice Resolves a rejected guardian application and refunds the bond
  /// @param guardian The guardian address
  function resolveRejectedApplication(address guardian) external {
    GuardianDetail storage guardianDetail = _requireExistingGuardian(guardian);

    if (guardianDetail.status != Status.Pending) {
      revert GuardianAdministrator__NoPendingApplication();
    }

    IGovernor.ProposalState state = governor.state(guardianDetail.proposalId);

    if (
      state != IGovernor.ProposalState.Defeated &&
      state != IGovernor.ProposalState.Canceled &&
      state != IGovernor.ProposalState.Expired
    ) {
      revert GuardianAdministrator__ProposalStillActive();
    }

    uint256 refund = guardianDetail.balance;

    guardianDetail.status = Status.Rejected;
    guardianDetail.balance = 0;

    if (refund > 0) {
      bondEscrow.refund(guardian, refund);
    }

    emit GuardianRejected(guardian, refund);
  }

  /// @notice Allows an active guardian to resign and reclaim the bonded stake
  function resignGuardian() external {
    address sender = msg.sender;
    GuardianDetail storage guardianDetail = guardians[sender];

    if (guardianDetail.status != Status.Active) {
      revert GuardianAdministrator__InvalidStatus();
    }

    uint256 refund = guardianDetail.balance;

    guardianDetail.status = Status.Resigned;
    guardianDetail.balance = 0;

    if (refund > 0) {
      bondEscrow.releaseOnResign(sender, refund);
    }

    emit GuardianResigned(sender, refund);
  }

  /// @notice Bans an active guardian and forfeits the bonded stake
  /// @param guardian The address of the guardian to ban
  function banGuardian(address guardian) external onlyTimelock {
    GuardianDetail storage guardianDetail = _requireExistingGuardian(guardian);

    if (guardianDetail.status != Status.Active) {
      revert GuardianAdministrator__InvalidStatus();
    }

    uint256 forfeit = guardianDetail.balance;

    guardianDetail.status = Status.Banned;
    guardianDetail.balance = 0;

    if (forfeit > 0) {
      bondEscrow.slashToTreasury(guardian, forfeit);
    }

    emit GuardianBanned(guardian, forfeit);
  }

  /// @notice Updates the minimum stake amount required for new guardian applications
  /// @param newMinStake The new minimum stake amount
  function setMinStake(uint256 newMinStake) external onlyTimelock {
    if (newMinStake == 0) revert GuardianAdministrator__InvalidStakeAmount();

    uint256 oldStake = minStake;
    minStake = newMinStake;

    emit MinStakeUpdated(oldStake, newMinStake);
  }

  /// @notice Returns the details of a guardian
  /// @param guardian The guardian address
  /// @return The guardian detail struct
  function getGuardianDetail(address guardian)
    external
    view
    returns (GuardianDetail memory)
  {
    GuardianDetail storage guardianDetail = _requireExistingGuardian(guardian);
    return guardianDetail;
  }

  /// @notice Returns the governance state of a pending guardian application
  /// @param guardian The guardian address
  /// @return The governor proposal state
  function getProposalState(address guardian)
    external
    view
    returns (IGovernor.ProposalState)
  {
    GuardianDetail storage guardianDetail = _requireExistingGuardian(guardian);

    if (guardianDetail.status != Status.Pending) {
      revert GuardianAdministrator__NoPendingApplication();
    }

    return governor.state(guardianDetail.proposalId);
  }

  /// @notice Checks whether an address is an active guardian
  /// @param guardian The address to check
  /// @return True if active, false otherwise
  function isActiveGuardian(address guardian) external view returns (bool) {
    _requireNonZeroAddress(guardian);
    return guardians[guardian].status == Status.Active;
  }

  /*//////////////////////////////////////////////////////////////
                          INTERNAL HELPERS
  //////////////////////////////////////////////////////////////*/

  function _requireNonZeroAddress(address addr) internal pure {
    if (addr == address(0)) revert GuardianAdministrator__ZeroAddress();
  }

  function _requireNonZeroAddresses(
    address addr1,
    address addr2,
    address addr3,
    address addr4
  ) internal pure {
    if (
      addr1 == address(0) ||
      addr2 == address(0) ||
      addr3 == address(0) ||
      addr4 == address(0)
    ) {
      revert GuardianAdministrator__ZeroAddress();
    }
  }

  function _requireExistingGuardian(address guardian)
    internal
    view
    returns (GuardianDetail storage guardianDetail)
  {
    _requireNonZeroAddress(guardian);

    guardianDetail = guardians[guardian];

    if (guardianDetail.status == Status.Inactive) {
      revert GuardianAdministrator__GuardianNotFound();
    }
  }
}