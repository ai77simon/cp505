// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC20Intact is IERC20, IERC20Metadata{
    function mint(address to, uint256 amount) external returns(bool);
    function burn(address from, uint256 amount) external returns(bool);
}