// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// =============================================================
//                           INTERFACE
// =============================================================

interface IStrategyAdapter {
  function execute(address vault, bytes calldata data) external;
}