// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// =============================================================
//                          INTERFACE
// =============================================================

interface IGuardianRegistry {
  function isActiveGuardian(address guardian) external view returns(bool);
}
