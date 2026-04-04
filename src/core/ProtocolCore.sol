// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// =============================================================
//                           IMPORTS
// =============================================================

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";


// =============================================================
//                          CONTRACTS
// =============================================================

contract ProtocolCore is
  Initializable,
  AccessControlUpgradeable,
  UUPSUpgradeable
{
  /*//////////////////////////////////////////////////////////////
                              STATE VARIABLES
  //////////////////////////////////////////////////////////////*/
  
  bytes32 public constant MANAGER_ROLE = keccak256('MANAGER_ROLE');
  bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
  mapping ( address => bool ) private _supportedAssets;
  bool public vaultCreationPaused;
  bool public depositsPaused;
  
  /*//////////////////////////////////////////////////////////////
                              EVENTS
  //////////////////////////////////////////////////////////////*/
  
  event SupportedAssetSet(address indexed asset, bool allowed);
  event VaultCreationPauseSet(bool paused);
  event DepositsPauseSet(bool paused);

  /*//////////////////////////////////////////////////////////////
                              ERRORS
  //////////////////////////////////////////////////////////////*/
  
  error ProtocolCore__InvalidAddress();

  /*//////////////////////////////////////////////////////////////
                              FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  
  // ==========================================================
  //                      CONSTRUCTOR
  // ==========================================================
  
  constructor() {
    _disableInitializers();
  }

  // ==========================================================
  //                      EXTERNAL
  // ==========================================================
  
  function initialize(
    address admin_,
    address emergencyOperator_
  ) external initializer {
    if(admin_ == address(0) || emergencyOperator_ == address(0)) revert ProtocolCore__InvalidAddress();

    __AccessControl_init();

    _grantRole(DEFAULT_ADMIN_ROLE, admin_);
    _grantRole(MANAGER_ROLE, admin_);
    _grantRole(EMERGENCY_ROLE, emergencyOperator_);   
  }

  function setSupportedAsset(
    address asset,
    bool allowed
  ) external onlyRole(MANAGER_ROLE) {
    if (asset == address(0)) revert ProtocolCore__InvalidAddress();

    _supportedAssets[asset] = allowed;
    emit SupportedAssetSet(asset, allowed);
  }

  function isAssetSupported(address asset) external view returns(bool) {
    return _supportedAssets[asset];
  }

  function pauseVaultCreation() external onlyRole(EMERGENCY_ROLE) {
    vaultCreationPaused = true;
    emit VaultCreationPauseSet(true);
  }

  function pauseDeposits() external onlyRole(EMERGENCY_ROLE) {
    depositsPaused = true;
    emit DepositsPauseSet(true);
  }

  function unpauseVaultCreation() external onlyRole(MANAGER_ROLE) {
      vaultCreationPaused = false;
      emit VaultCreationPauseSet(false);
  }

  function unpauseDeposits() external onlyRole(MANAGER_ROLE) {
    depositsPaused = false;
    emit DepositsPauseSet(false);
  }

  function _authorizeUpgrade( 
    address newImplementation
  ) internal override onlyRole(DEFAULT_ADMIN_ROLE){}
}