// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// =============================================================
//                           IMPORTS
// =============================================================

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IGovernor } from "@openzeppelin/contracts/governance/IGovernor.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

// =============================================================
//                          CONTRACTS
// =============================================================

/// @title GuardianAdministrator
/// @author Julian Ruiz
/// @notice Contract for managing guardian applications, approvals, and bans
/// @dev Handles staking, governance proposals, and guardian status lifecycle

contract GuardianAdministrator {
  /*//////////////////////////////////////////////////////////////
                        TYPE DECLARATIONS
  //////////////////////////////////////////////////////////////*/
  
  using SafeERC20 for IERC20;
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
                              STATE VARIABLES
  //////////////////////////////////////////////////////////////*/
  
  /// @notice Minimum stake amount required to become a guardian
  uint256 public minStake;
  /// @notice Token used for staking
  IERC20 public immutable boundingToken;
  /// @notice Governor contract for guardian approvals
  IGovernor public immutable governor;
  /// @notice Timelock contract address
  address public immutable timelock;
  /// @notice Treasury address for forfeited stakes
  address public immutable treasury;
  /// @notice Mapping of guardian addresses to their details
  mapping(address => GuardianDetail) private guardians;

  /*//////////////////////////////////////////////////////////////
                              EVENTS
  //////////////////////////////////////////////////////////////*/
  
  /// @notice Emitted when a guardian applies
  event GuardianApplied(address indexed guardian, uint256 indexed proposalId);
  /// @notice Emitted when a guardian is approved
  event GuardianApproved(address indexed guardian);
  /// @notice Emitted when a guardian application is rejected
  event GuardianRejected(address indexed guardian, uint256 stakeRefunded);
  /// @notice Emitted when a guardian resigns
  event GuardianResigned(address indexed guardian, uint256 stakeRefunded);
  /// @notice Emitted when a guardian is banned
  event GuardianBanned(address indexed guardian, uint256 stakeForFeit);
  /// @notice Emitted when minimum stake is updated
  event MinStakeUpdated(uint256 oldStake, uint256 newStake);

  /*//////////////////////////////////////////////////////////////
                              ERRORS
  //////////////////////////////////////////////////////////////*/
  
  /// @notice Error thrown when guardian stake is below minimum
  error GuardianAdministrator__InsufficientBalance();
  /// @notice Error thrown when guardian has already applied
  error GuardianAdministrator__AlreadyApplied();
  /// @notice Error thrown when address is invalid (zero address)
  error GuardianAdministrator__InvalidAddress();
  /// @notice Error thrown when guardian status is invalid for operation
  error GuardianAdministrator__InvalidStatus();
  /// @notice Error thrown when there is no pending application
  error GuardianAdministrator__NoPendingAplication();
  /// @notice Error thrown when proposal is still active
  error GuardianAdministrator__ProposalStillActive();
  /// @notice Error thrown when caller is not authorized
  error GuardianAdministrator__NotAuthorized();
  /// @notice Error thrown when stake amount is invalid
  error GuardianAdministrator__InvalidStakeAmount();

  /*//////////////////////////////////////////////////////////////
                              MODIFIERS
  //////////////////////////////////////////////////////////////*/
  
  /// @notice Modifier to check if caller is the timelock
  modifier onlyTimelock() {
    if (msg.sender != timelock) revert GuardianAdministrator__NotAuthorized();
    _;
  }

  /*//////////////////////////////////////////////////////////////
                              FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  
  // ==========================================================
  //                      CONSTRUCTOR
  // ==========================================================
  
  /// @notice Initializes the GuardianAdministrator contract
  /// @param boundingToken_ The ERC20 token used for staking
  /// @param governor_ The governor contract for approvals
  /// @param timelock_ The timelock contract address
  /// @param treasury_ The treasury address for forfeited stakes
  /// @param minStake_ The minimum stake amount required
  /// @dev Reverts if any address is zero or minStake is zero
  constructor(
    IERC20 boundingToken_,
    IGovernor governor_,
    address timelock_,
    address treasury_,
    uint256 minStake_
  ) {
    if (address(boundingToken_) == address(0)) revert GuardianAdministrator__InvalidAddress();
    if (address(governor_) == address(0)) revert GuardianAdministrator__InvalidAddress();
    if (timelock_ == address(0)) revert GuardianAdministrator__InvalidAddress();
    if (treasury_ == address(0)) revert GuardianAdministrator__InvalidAddress();
    if (minStake_ == 0) revert GuardianAdministrator__InvalidStakeAmount();

    boundingToken = boundingToken_;
    governor = governor_;
    timelock = timelock_;
    treasury = treasury_;
    minStake = minStake_;
 }

  // ==========================================================
  //                      EXTERNAL
  // ==========================================================
  
  /// @notice Allows a user to apply as a guardian by staking tokens
  /// @dev Creates a governance proposal for guardian approval. Reverts if already applied
  function applyGuardian() external {
    address sender = msg.sender;
    GuardianDetail storage guardian = guardians[sender];

    if (guardians[sender].status != Status.Inactive)
      revert GuardianAdministrator__AlreadyApplied();

    guardian.status = Status.Pending;
    guardian.balance = minStake;
    guardian.blockRequest = block.number;

    boundingToken.safeTransferFrom(sender, address(this), minStake);

    address[] memory targets =  new address[](1);
    uint256[] memory values = new uint256[](1);
    bytes[] memory calldatas = new bytes[](1);

    targets[0] = address(this);
    values[0] = 0;
    calldatas[0] = abi.encodeCall(this.GuardianApprove, (sender));

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

    guardian.proposalId = proposalId;

    emit GuardianApplied(sender, proposalId);
  }

  /// @notice Approves a guardian application (called by timelock after proposal passes)
  /// @param guardian The address of the guardian to approve
  /// @dev Only callable by timelock. Reverts if address is zero or status is not Pending
  function GuardianApprove(address guardian) external onlyTimelock {
    if (guardian == address(0)) revert GuardianAdministrator__InvalidAddress();
    
    GuardianDetail storage guardianUser = guardians[guardian];

    if (guardianUser.status != Status.Pending) revert GuardianAdministrator__InvalidStatus();

    guardianUser.status = Status.Active;

    emit GuardianApproved(guardian);
  }

  /// @notice Resolves a rejected application and refunds the stake
  /// @param guardian The address of the guardian
  /// @dev Refunds stake if proposal is defeated, canceled, or expired
  function resolveRejectedApplication(address guardian) external {
    GuardianDetail storage guardianUser = guardians[guardian];

    if (guardianUser.status != Status.Pending) revert GuardianAdministrator__NoPendingAplication();

    IGovernor.ProposalState state = governor.state(
      guardianUser.proposalId
    );

    if (
      state != IGovernor.ProposalState.Defeated &&
      state != IGovernor.ProposalState.Canceled &&
      state != IGovernor.ProposalState.Expired
    ) revert GuardianAdministrator__ProposalStillActive();

    uint256 refund = guardianUser.balance;

    guardianUser.status = Status.Rejected;
    guardianUser.balance = 0;

    boundingToken.safeTransfer(guardian, refund);

    emit GuardianRejected(guardian, refund);
  }

  /// @notice Allows an active guardian to resign and reclaim their stake
  /// @dev Reverts if caller is not an active guardian
  function resignGuardian() external {
    GuardianDetail storage guardianUser = guardians[msg.sender];

    if (guardianUser.status != Status.Active) revert GuardianAdministrator__InvalidStatus();

    uint256 refund = guardianUser.balance;
    guardianUser.status = Status.Resigned;
    guardianUser.balance = 0;

    boundingToken.safeTransfer(msg.sender, refund);

    emit GuardianResigned(msg.sender, refund);
  }

  /// @notice Bans an active guardian and forfeits their stake to treasury
  /// @param guardian The address of the guardian to ban
  /// @dev Only callable by timelock. Reverts if address is zero or guardian not active
  function banGuardian(address guardian) external onlyTimelock() {
    if (guardian == address(0)) revert GuardianAdministrator__InvalidAddress();

    GuardianDetail storage guardianUser = guardians[guardian];

    if (guardianUser.status != Status.Active) revert GuardianAdministrator__InvalidStatus();

    uint256 forfeit = guardianUser.balance;
    guardianUser.status = Status.Banned;
    guardianUser.balance = 0;

    if (forfeit > 0) boundingToken.safeTransfer(treasury, forfeit);
    
    emit GuardianBanned(guardian, forfeit);
  }

  /// @notice Updates the minimum stake amount
  /// @param newMinStake The new minimum stake amount
  /// @dev Only callable by timelock. Reverts if newMinStake is zero
  function setMinStake(uint256 newMinStake) external onlyTimelock{
    if (newMinStake == 0) revert GuardianAdministrator__InvalidStakeAmount();

    uint256 old = minStake;
    minStake = newMinStake;

    emit MinStakeUpdated(old, newMinStake);
  }

  // ==========================================================
  //                         EXTERNAL VIEW
  // ==========================================================
  
  /// @notice Returns the details of a guardian
  /// @param guardian The guardian address
  /// @return The GuardianDetail struct
  /// @dev Reverts if guardian does not exist (status is Inactive)
  function getGuardianDetail(address guardian) 
    external 
    view 
    returns(GuardianDetail memory) 
  {
    if (guardians[guardian].status == Status.Inactive) revert GuardianAdministrator__InvalidAddress();

    return guardians[guardian];
  }

  /// @notice Returns the governance state of a pending guardian application
  /// @param guardian The guardian address
  /// @return The ProposalState from the governor
  /// @dev Reverts if guardian does not have a Pending application
  function getProposalState(address guardian) 
    external
    view
    returns(IGovernor.ProposalState)
  {
    if (guardians[guardian].status != Status.Pending) revert GuardianAdministrator__NoPendingAplication();

    return governor.state(guardians[guardian].proposalId);
  }

  /// @notice Checks if an address is an active guardian
  /// @param guardian The address to check
  /// @return True if the address is an active guardian
  function IsActiveGuardian(address guardian) external view returns(bool) {
    return guardians[guardian].status == Status.Active;
  }
}
