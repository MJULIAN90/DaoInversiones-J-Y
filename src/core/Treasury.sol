// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// =============================================================
//                           IMPORTS
// =============================================================

import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

// =============================================================
//                          CONTRACTS
// =============================================================

contract Treasury is ReentrancyGuardTransient {
  /*//////////////////////////////////////////////////////////////
                              TYPE DECLARATIONS
  //////////////////////////////////////////////////////////////*/
  
  using SafeERC20 for IERC20;
  using Address for address payable;

  /*//////////////////////////////////////////////////////////////
                              STATE VARIABLES
  //////////////////////////////////////////////////////////////*/
  
  address public immutable timelock;

  /*//////////////////////////////////////////////////////////////
                              EVENTS
  //////////////////////////////////////////////////////////////*/
  
  event NativeReceived(address indexed sender, uint256 amount);

  event ERC20Withdrawn(
    address indexed token,
    address indexed to,
    uint amount
  );

  event NativeWithdrawn(
    address indexed to,
    uint256 amount
  );

  event ExternalCallExecute(
    address indexed target,
    uint256 value,
    bytes data,
    bytes result
  );

  /*//////////////////////////////////////////////////////////////
                              ERRORS
  //////////////////////////////////////////////////////////////*/
  
    error Treasury__NotAuthorized();
    error Treasury__InvalidAddress();
    error Treasury__ZeroAmount();
    error Treasury__InsufficientNativeBalance();
    error Treasury__CallFailed();

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/
    
    modifier onlyTimelock() {
      if (msg.sender != timelock) revert Treasury__NotAuthorized();
      _;
    }

    /*//////////////////////////////////////////////////////////////
                                FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    // ==========================================================
    //                      CONSTRUCTOR
    // ==========================================================
    
    constructor(address timelock_) {
      if (timelock_ == address(0)) revert Treasury__InvalidAddress();

      timelock = timelock_;
    }

    // ==========================================================
    //                      RECEIVE
    // ==========================================================
    
    receive() external payable {
      emit NativeReceived(msg.sender, msg.value);
    }

    // ==========================================================
    //                      EXTERNAL
    // ==========================================================
    
    function withdrawERC20(
      address token,
      address to,
      uint256 amount
    ) external onlyTimelock nonReentrant {
      if (token == address(0) || to == address(0)) revert Treasury__InvalidAddress();

      if (amount == 0) revert Treasury__ZeroAmount();

      IERC20(token).safeTransfer(to, amount);

      emit ERC20Withdrawn(token, to, amount);
    }

    function withdrawNative(
      address payable to,
      uint256 amount
    ) external onlyTimelock nonReentrant {
      if (to == address(0)) revert Treasury__InvalidAddress();
      if (amount == 0) revert Treasury__ZeroAmount();
      if (address(this).balance > amount) revert Treasury__InsufficientNativeBalance();

      to.sendValue(amount);

      emit NativeWithdrawn(to, amount);
    }

    function execute(
      address target,
      uint256 value,
      bytes calldata data
    ) 
      external onlyTimelock nonReentrant
      returns(bytes memory) 
    {
      if(target == address(0)) revert Treasury__InvalidAddress();
      
      (bool success, bytes memory returnData) = target.call{value: value}(data);
      if (!success) revert Treasury__CallFailed();

      emit ExternalCallExecute(target, value, data, returnData);

      return returnData;
    }

    function nativeBalance() external view returns(uint256) {
      return address(this).balance;
    }

    function erc20Balance(address token) external view returns(uint256) {
      if (token == address(0)) revert Treasury__InvalidAddress();
      return IERC20(token).balanceOf(address(this));
    }
}