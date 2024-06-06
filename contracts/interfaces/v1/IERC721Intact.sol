// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IERC721Intact is IERC721,IERC721Enumerable{

    function mint(address to,uint8 team) external returns(bool);

    function burn(uint tokenId) external returns(bool);

    function mintBatch(address to,uint8[] memory teams,uint[] memory amounts) external returns (bool);

    function burnBatch(uint[] memory tokenIds) external returns (bool);

    function transfer(address to,uint tokenId) external returns (bool);

    function getTeam(uint tokenId) external view returns (uint8);

    function getTeamCount(uint8 team) external view returns (uint);

    function getTeamCountList() external view returns (uint[] memory);

    function getOwnerTeamCount(address owner, uint8 team) external view returns (uint);

    function getOwnerTeamCountList(address owner) external view returns (uint[] memory);

    function getOwnerTeamTokenIds(address owner, uint8 team) external view returns (uint[] memory);

    function getOwnerTokenIds(address owner)  external view returns (uint[2][] memory);
}