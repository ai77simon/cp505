// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "../../interfaces/v1/IERC20Intact.sol";

contract VoucherToken is Context,AccessControlEnumerable,ERC20Pausable,IERC20Intact {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");
    event Minted(address indexed to, uint indexed amount);
    event Burned(address indexed from, uint indexed amount);

    constructor() ERC20("Voucher", "UEFA") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GOVERNOR_ROLE, msg.sender);
        _setRoleAdmin(GOVERNOR_ROLE,DEFAULT_ADMIN_ROLE);
    }

    function mint(address to, uint256 amount) external whenNotPaused onlyRole(MINTER_ROLE) returns(bool){
        require(amount > 0, "ERC20: mint amount should be greater than zero");
        _mint(to,amount);
        emit Minted(to,amount);
        return true;
    }

    function burn(address from, uint256 amount) external whenNotPaused onlyRole(BURNER_ROLE) returns(bool){
        require(amount > 0, "ERC20: burn amount should be greater than zero");
        _burn(from,amount);
        emit Burned(from,amount);
        return true;
    }

    function pause() external onlyRole(GOVERNOR_ROLE) returns(bool){
        _pause();
        return true;
    }

    function unpause() external onlyRole(GOVERNOR_ROLE) returns(bool){
        _unpause();
        return true;
    }

}