// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20, IERC165 {
  constructor() ERC20("MockERC20", "MERC20") {}

  function mint(address to, uint256 amount) external {
    _mint(to, amount);
  }

  function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
    return interfaceId == type(IERC165).interfaceId;
  }
}
