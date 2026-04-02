// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// =============================================================
//                           IMPORTS
// =============================================================

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Votes } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

// =============================================================
//                          CONTRACTS
// =============================================================

/// @title GovernanceToken
/// @author Julian Ruiz
/// @notice Governance token for the DAO with voting delegation functionality
/// @dev Implements ERC20 with EIP712 for digital signatures and ERC20Votes for delegated voting

contract GovernanceToken is ERC20, EIP712, ERC20Votes, Ownable {
  /*//////////////////////////////////////////////////////////////
                              STATE VARIABLES
  //////////////////////////////////////////////////////////////*/
  
  /// @notice Indicates whether minting of new tokens has been disabled
  bool public mintingFinished;

  /*//////////////////////////////////////////////////////////////
                              EVENTS
  //////////////////////////////////////////////////////////////*/
  
  /// @notice Emitted when token minting is disabled
  event MintingClosed();

  /*//////////////////////////////////////////////////////////////
                              ERRORS
  //////////////////////////////////////////////////////////////*/
  
  /// @notice Error thrown when attempting to mint after minting has been disabled
  error GovernanceToken__MintingDisabled();

  /*//////////////////////////////////////////////////////////////
                              FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  // ==========================================================
  //                      CONSTRUCTOR
  // ==========================================================
  
  /// @notice Initializes the governance token
  /// @param initialOwner The address of the initial contract owner
  /// @dev Sets the token name, symbol, and EIP712 domain for signatures
  constructor(address initialOwner)
    ERC20("GovernanceToken_J&Y", "J&Y_Token")
    EIP712("GovernanceToken_J&Y", "1")
    Ownable(initialOwner)
  {}

  // ==========================================================
  //                      EXTERNAL
  // ==========================================================
  
  /// @notice Mints new governance tokens
  /// @param to The address that will receive the minted tokens
  /// @param amount The amount of tokens to mint
  /// @dev Only the owner can mint tokens. Reverts if minting has been disabled
  function mint(address to, uint256 amount) external onlyOwner {
    if(mintingFinished) revert GovernanceToken__MintingDisabled();
    _mint(to,amount);
  }

  /// @notice Permanently disables minting of new tokens
  /// @dev Only the owner can call this function. Emits MintingClosed event
  function finishMinting() external onlyOwner {
    mintingFinished = true;
    emit MintingClosed();
  }

  // ==========================================================
  //                      INTERNAL
  // ==========================================================
  
  /// @notice Updates token balances and records voting delegations
  /// @param from The address sending tokens
  /// @param to The address receiving tokens
  /// @param value The amount of tokens transferred
  /// @dev Override that combines ERC20 and ERC20Votes to maintain voting history
  function _update(
    address from, 
    address to, 
    uint256 value
  ) internal override(ERC20, ERC20Votes) {
    super._update(from, to, value);
  }
}
