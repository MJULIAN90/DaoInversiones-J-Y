// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// =============================================================
//                           IMPORTS
// =============================================================

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { ERC4626Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { IProtocolCore } from "../interfaces/IProtocolCore.sol";

// =============================================================
//                          CONTRACTS
// =============================================================

contract VaultImplementation is
  Initializable,
  ERC20Upgradeable,
  ERC4626Upgradeable,
  AccessControlUpgradeable,
  PausableUpgradeable,
  ReentrancyGuardTransient 
{
  /*//////////////////////////////////////////////////////////////
                              STATE VARIABLES
  //////////////////////////////////////////////////////////////*/
  
  address public guardian;
  address public factory;
  address public router;
  address core;

  /*//////////////////////////////////////////////////////////////
                              EVENTS
  //////////////////////////////////////////////////////////////*/
  
  event VaultInitialized(
    address indexed asset,
    address indexed guardina,
    address indexed admin,
    address factory,
    address router,
    address core
  );

  event RouterUpdated(address indexed oldRouter, address indexed newRouter);
  event CoreUpdated(address indexed oldCore, address indexed newCore);

  /*//////////////////////////////////////////////////////////////
                              ERRORS
  //////////////////////////////////////////////////////////////*/
  
  error VaultImplementation__ZeroAddress();
  error VaultImplementation__NotFactory();
  error VaultImplementation__DepositsPaused();

  /*//////////////////////////////////////////////////////////////
                              FUNCTIONS
  //////////////////////////////////////////////////////////////*/
  
  // ==========================================================
  //                      CONSTRUCTOR
  // ==========================================================
  
  constructor(){
    _disableInitializers();
  }

  // ==========================================================
  //                      EXTERNAL
  // ==========================================================
  
  function initialize(
    address asset_,
    string memory name_,
    string memory symbol_,
    address guardian_,
    address admin_,
    address factory_,
    address router_,
    address core_
  ) external initializer {
    _requireNonZeroAddresses(
      asset_,
      guardian_,
      admin_,
      factory_,
      router_,
      core_
    );

    if(msg.sender != factory_) revert VaultImplementation__NotFactory();

    __ERC20_init(name_, symbol_);
    __ERC4626_init(IERC20(asset_));
    __AccessControl_init();
    __Pausable_init();

    guardian = guardian_;
    factory = factory_;
    router = router_;
    core = core_;

    _grantRole(DEFAULT_ADMIN_ROLE, admin_);

    emit VaultInitialized(
      asset_,
      guardian_,
      admin_,
      factory_,
      router_,
      core_
    );
  }

  function setRouter(address newRouter) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _requireNonZeroAddress(newRouter);
  
    address oldRouter = router;
    router = newRouter;

    emit RouterUpdated(oldRouter, newRouter);
  }

  function setCore(address newCore) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _requireNonZeroAddress(newCore);

    address oldCore = core;
    core = newCore;

    emit CoreUpdated(oldCore, newCore);
  }

  function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
    _pause();
  }

  function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
    _unpause();
  }

  // ==========================================================
  //                      PUBLIC
  // ==========================================================
  
  function deposit(uint256 assets, address receiver) 
    public
    override
    whenNotPaused
    nonReentrant
    returns(uint256 shares)
  {
    if (IProtocolCore(core).depositsPaused()) revert VaultImplementation__DepositsPaused();

    return super.deposit(assets, receiver);
  }

  function mint(uint256 shares, address receiver)
    public
    override
    whenNotPaused
    nonReentrant
    returns(uint256 assets)
  {
    if (IProtocolCore(core).depositsPaused()) revert VaultImplementation__DepositsPaused();
    
    return super.mint(shares, receiver);
  }

  function withdraw(
    uint256 assets,
    address receiver,
    address owner
  )
    public
    override
    whenNotPaused
    nonReentrant
    returns(uint256 shares)
  {
    return super.withdraw(assets, receiver, owner);
  }

  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) 
    public
    override
    whenNotPaused
    nonReentrant
    returns(uint256 assets) 
  {
    return super.redeem(shares, receiver, owner);
  }

  function decimals()
    public
    view
    override(ERC20Upgradeable, ERC4626Upgradeable)
    returns(uint8) 
  {
    return ERC20Upgradeable.decimals();
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(AccessControlUpgradeable)
    returns(bool) 
  {
    return super.supportsInterface(interfaceId);
  }

  // ==========================================================
  //                      INTERNAL
  // ==========================================================
    
  function _requireNonZeroAddresses(
    address addr1,
    address addr2,
    address addr3,
    address addr4,
    address addr5,
    address addr6
  ) internal pure {
    if (
      addr1 == address(0) ||
      addr2 == address(0) ||
      addr3 == address(0) ||
      addr4 == address(0) ||
      addr5 == address(0) ||
      addr6 == address(0)
    ) {
      revert VaultImplementation__ZeroAddress();
    }
  }

  function _requireNonZeroAddress( address addr ) internal pure {
    if ( addr == address(0) ) {
      revert VaultImplementation__ZeroAddress();
    }
  }
}

