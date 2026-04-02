// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// =============================================================
//                           IMPORTS
// =============================================================

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";

// =============================================================
//                          CONTRACTS
// =============================================================

/// @title TimeLock
/// @author Julian Ruiz
/// @notice Timelock contract for the DAO that adds a delay to approved proposals
/// @dev Extends OpenZeppelin's TimelockController for managing delayed executions

contract TimeLock is TimelockController {

  /*//////////////////////////////////////////////////////////////
                              FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  
  // ==========================================================
  //                      CONSTRUCTOR
  // ==========================================================
  
  /// @notice Initializes the TimeLock with delay parameters and roles
  /// @param minDelay The minimum delay in seconds before executing a proposal
  /// @param proposers Array of addresses with proposer role
  /// @param executors Array of addresses with executor role
  /// @param admin The address of the timelock administrator (can be address(0))
  /// @dev The minDelay should be sufficient to give users time to review the proposal
  constructor(
    uint256 minDelay,
    address[] memory proposers,
    address[] memory executors,
    address admin
  ) TimelockController(
      minDelay, 
      proposers,
      executors,
      admin
    ){}
}