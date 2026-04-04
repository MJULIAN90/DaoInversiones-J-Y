// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// =============================================================
//                          INTERFACE
// =============================================================

interface IVaulRegistry {
  function registerVaul(
    address vault,
    address guardian,
    address asset
  ) external;

  function getVaultByAssetAndGuardian(
    address asset,
    address guardian
  ) external
    view
    returns(address);
}