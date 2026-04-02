// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// =============================================================
//                           IMPORTS
// =============================================================

import { Governor } from "@openzeppelin/contracts/governance/Governor.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import { GovernorStorage } from "@openzeppelin/contracts/governance/extensions/GovernorStorage.sol";
import { GovernorTimelockControl } from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import { GovernorVotes } from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import { GovernorVotesQuorumFraction } from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";

// =============================================================
//                          CONTRACTS
// =============================================================

/// @title DaoGovernor
/// @author Julian Ruiz
/// @notice Governance governor contract for the DAO with timelock integration
/// @dev Extends OpenZeppelin Governor with counting, storage, voting, and timelock control 

contract DaoGovernor is 
  Governor,
  GovernorCountingSimple,
  GovernorStorage,
  GovernorVotes,
  GovernorVotesQuorumFraction,
  GovernorTimelockControl 
{
  /*//////////////////////////////////////////////////////////////
                              STATE VARIABLES
  //////////////////////////////////////////////////////////////*/
  
  /// @notice Delay between proposal creation and voting start
  uint48 private _votingDelay;
  /// @notice Duration of the voting period
  uint48 private _votingPeriod;
  /// @notice Number of votes required to propose
  uint256 private _proposalThreshold;

  /*//////////////////////////////////////////////////////////////
                              FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  
  // ==========================================================
  //                      CONSTRUCTOR
  // ==========================================================
  
  /// @notice Initializes the governor with voting parameters
  /// @param _token The IVotes token contract for voting
  /// @param _timelock The TimelockController for delayed execution
  /// @param votingDelay_ Delay in blocks between proposal creation and voting start
  /// @param votingPeriod_ Duration in blocks of the voting period
  /// @param proposalThreshold_ Number of votes required to create a proposal
  /// @dev Sets quorum fraction to 4% by default
  constructor(
    IVotes _token,
    TimelockController _timelock,
    uint48 votingDelay_, 
    uint32 votingPeriod_,
    uint256 proposalThreshold_
  )
    Governor("DaoGovernor")
    GovernorVotes(_token)
    GovernorVotesQuorumFraction(4)
    GovernorTimelockControl(_timelock)
  {
    _votingDelay = votingDelay_;
    _votingPeriod = votingPeriod_;
    _proposalThreshold = proposalThreshold_;
  }

  // ==========================================================
  //                      PUBLIC
  // ==========================================================
  
  /// @notice Returns the delay between proposal creation and voting start
  /// @return The voting delay in blocks
  function votingDelay() public view override returns(uint256) {
    return _votingDelay;
  }

  /// @notice Returns the duration of the voting period
  /// @return The voting period in blocks
  function votingPeriod() public view override returns(uint256) {
    return _votingPeriod;
  }

  /// @notice Returns the current state of a proposal
  /// @param proposalId The ID of the proposal
  /// @return The current ProposalState
  function state(uint256 proposalId)
    public
    view
    override(Governor, GovernorTimelockControl)
    returns(ProposalState)
  {
    return super.state(proposalId);
  }

  /// @notice Returns the number of votes required to create a proposal
  /// @return The proposal threshold
  function proposalThreshold() public view override returns(uint256) {
    return _proposalThreshold;
  }

  /// @notice Checks if a proposal needs queuing before execution
  /// @param proposalId The ID of the proposal
  /// @return True if the proposal needs queuing
  function proposalNeedsQueuing(uint256 proposalId)
    public
    view
    override(Governor, GovernorTimelockControl)
    returns(bool)
  {
    return super.proposalNeedsQueuing(proposalId);
  } 

  // ==========================================================
  //                      INTERNAL
  // ==========================================================
  
  /// @notice Creates a new proposal
  /// @param targets Array of target addresses to call
  /// @param values Array of ETH values to send
  /// @param calldatas Array of calldata for each call
  /// @param description The proposal description
  /// @param proposer The address creating the proposal
  /// @return The proposal ID
  function _propose(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    string memory description,
    address proposer
  )
    internal
    override(Governor, GovernorStorage)
    returns(uint256)
  {
    return super._propose(
      targets,
      values,
      calldatas,
      description,
      proposer
    );
  }

  /// @notice Queues a proposal for timelocked execution
  /// @param proposalId The ID of the proposal
  /// @param targets Array of target addresses to call
  /// @param values Array of ETH values to send
  /// @param calldatas Array of calldata for each call
  /// @param descriptionHash The hash of the proposal description
  /// @return The timestamp when the proposal will be executable
  function _queueOperations(
    uint256 proposalId,
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
  )
    internal
    override(Governor, GovernorTimelockControl)
    returns(uint48)
  {
    return super._queueOperations(
      proposalId,
      targets,
      values,
      calldatas,
      descriptionHash
    );
  }

  /// @notice Executes a queued proposal
  /// @param proposalId The ID of the proposal
  /// @param targets Array of target addresses to call
  /// @param values Array of ETH values to send
  /// @param calldatas Array of calldata for each call
  /// @param descriptionHash The hash of the proposal description
  function _executeOperations(
    uint256 proposalId,
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
  )
    internal
    override(Governor, GovernorTimelockControl)
  {
    super._executeOperations(
      proposalId,
      targets,
      values,
      calldatas,
      descriptionHash
    );  
  }

  /// @notice Cancels a proposal
  /// @param targets Array of target addresses
  /// @param values Array of ETH values
  /// @param calldatas Array of calldata
  /// @param descriptionHash The hash of the description
  /// @return The proposal ID
  function _cancel(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
  )
    internal
    override(Governor, GovernorTimelockControl)
    returns(uint256)
  {
    return super._cancel(
      targets,
      values,
      calldatas,
      descriptionHash
    );
  }

  /// @notice Returns the executor address for timelock operations
  /// @return The executor address
  function _executor()
    internal
    view
    override(Governor, GovernorTimelockControl)
    returns(address)
  {
    return super._executor();
  }
}
