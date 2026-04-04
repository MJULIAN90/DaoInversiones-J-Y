// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

// =============================================================
//                          INTERFACE
// =============================================================
interface IGovernanceToken {
    function mint(address to, uint256 amount) external;
}