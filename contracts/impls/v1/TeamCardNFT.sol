// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "../../interfaces/v1/IERC721Intact.sol";
import "../../interfaces/v1/IBlast.sol";
import "../../interfaces/v1/IBlastPoints.sol";

contract TeamCardNFT is ERC721Enumerable,AccessControlEnumerable,Pausable,IERC721Intact {
    using Counters for Counters.Counter;
    using Strings for uint256;
    using Strings for uint8;
    using Address for address;
    Counters.Counter private _tokenIds;

    // Team abbreviation
    string[24] private _teamNames = [
        "GER",   // team = 0
        "SCO",   // team = 1
        "HUN",   // team = 2
        "SUI",   // team = 3
        "ESP",   // team = 4
        "CRO",   // team = 5
        "ITA",   // team = 6
        "ALB",   // team = 7
        "SVN",   // team = 8
        "DEN",   // team = 9
        "SRB",   // team = 10
        "ENG",   // team = 11
        "NED",   // team = 12
        "FRA",   // team = 13
        "POL",   // team = 14
        "AUT",   // team = 15
        "UKR",   // team = 16
        "SVK",   // team = 17
        "BEL",   // team = 18
        "ROU",   // team = 19
        "POR",   // team = 20
        "CZE",   // team = 21
        "GEO",   // team = 22
        "TUR"    // team = 23
    ];

    // Team full name
    string[24] private _teamDescs = [
        "Germany",       // team = 0
        "Scotland",      // team = 1
        "Hungary",       // team = 2
        "Switzerland",   // team = 3
        "Spain",         // team = 4
        "Croatia",       // team = 5
        "Italy",         // team = 6
        "Albania",       // team = 7
        "Slovenia",      // team = 8
        "Denmark",       // team = 9
        "Serbia",        // team = 10
        "England",       // team = 11
        "Netherlands",   // team = 12
        "France",        // team = 13
        "Poland",        // team = 14
        "Austria",       // team = 15
        "Ukraine",       // team = 16
        "Slovakia",      // team = 17
        "Belgium",       // team = 18
        "Romania",       // team = 19
        "Portugal",      // team = 20
        "Czechia",       // team = 21
        "Georgia",       // team = 22
        "Turkiye"        // team = 23
    ];
    
    // Mapping from token ID to team attribute
    mapping(uint => uint8) private _teams;

    // Mapping from team to count of NFTs in that team
    mapping(uint8 => uint) private _teamCounts;

    // Mapping from owner to team to count of NFTs
    mapping(address => mapping(uint8 => uint)) private _ownerTeamCounts;

    // Define roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    // Events
    event TokenMinted(address indexed to, uint indexed tokenId, uint8 indexed team);
    event TokenBurned(uint indexed tokenId, uint8 indexed team);
    event TokenTransfer(address indexed from, address indexed to, uint indexed tokenId);

    constructor(address blastPointsAddress) ERC721("TeamCardNFT", "TCARD") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GOVERNOR_ROLE, msg.sender);
        _setRoleAdmin(GOVERNOR_ROLE,DEFAULT_ADMIN_ROLE);

        // This sets the Gas Mode for MyContract to claimable
        IBlast(0x4300000000000000000000000000000000000002).configureClaimableGas();
        IBlast(0x4300000000000000000000000000000000000002).configureGovernor(msg.sender);

        // BlastPoints Testnet address: 0x2fc95838c71e76ec69ff817983BFf17c710F34E0
        // BlastPoints Mainnet address: 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800
        IBlastPoints(0x2fc95838c71e76ec69ff817983BFf17c710F34E0).configurePointsOperator(blastPointsAddress);
     }

    // Minting a single NFT, Only the EuroCup contract can be called
    function mint(address to,uint8 team) public whenNotPaused onlyRole(MINTER_ROLE) returns (bool){
        require(team >= 0 && team <= 23, "Team must be between 0 and 23");
        require(!to.isContract(), "Cannot mint to a contract address");
        _tokenIds.increment();
        uint tokenId = _tokenIds.current();
        _teams[tokenId] = team;
        _teamCounts[team] += 1;
        _mint(to, tokenId);
        emit TokenMinted(to, tokenId, team);
        return true;
    }

    // Batch minting NFTs
    function mintBatch(address to,uint8[] memory teams,uint[] memory amounts) external onlyRole(MINTER_ROLE) returns (bool){
        for(uint8 i = 0; i < teams.length; i++){
            for(uint j = 0; j < amounts[i]; j++){
                mint(to,teams[i]);
            }
        }
        return true;
    }

    // Burning a single NFT, Only the EuroCup contract can be called
    function burn(uint tokenId) public whenNotPaused onlyRole(BURNER_ROLE) returns (bool){
        uint8 team = _teams[tokenId];
        _teamCounts[team] -=1;
        _burn(tokenId);
        delete _teams[tokenId];
        emit TokenBurned(tokenId, team);
        return true;
    }

    // Batch burning NFTs
    function burnBatch(uint[] memory tokenIds) external onlyRole(BURNER_ROLE) returns (bool){
        for(uint i = 0; i < tokenIds.length; i++){
            burn(tokenIds[i]);
        }
        return true;
    }

    // Transferring NFTs
    function transfer(address to,uint tokenId) external whenNotPaused returns (bool){
        _transfer(msg.sender,to,tokenId);
        emit TokenTransfer(msg.sender,to,tokenId);
        return true;
    }

    /**
     * @dev Returns the team attribute for a specific token ID.
     * @param tokenId The ID of the token.
     * @return The team attribute of the token.
     */
    function getTeam(uint tokenId) public view returns (uint8) {
        require(_exists(tokenId), "ERC721Metadata: Team query for nonexistent token");
        return _teams[tokenId];
    }

    /**
     * @dev Returns the number of NFTs in a specific team.
     * @param team The team attribute.
     * @return The number of NFTs in the team.
     */
    function getTeamCount(uint8 team) public view returns (uint) {
        require(team >= 0 && team <= 23, "Team must be between 0 and 23");
        return _teamCounts[team];

    }

    // Get the count of all teams
    function getTeamCountList() public view returns (uint[] memory) {
        uint[] memory counts = new uint[](24);
        for(uint8 i=0;i<24;i++){
            counts[i] = getTeamCount(i);
        }
        return counts;
    }

    /**
     * @dev Returns the number of NFTs a specific address owns in a specific team.
     * @param owner The address of the owner.
     * @param team The team attribute.
     * @return The number of NFTs the address owns in the team.
     */
    function getOwnerTeamCount(address owner, uint8 team) public view returns (uint) {
        require(team >= 0 && team <= 23, "Team must be between 0 and 23");
        return _ownerTeamCounts[owner][team];
    }

    // Get the count of all teams belonging to owner
    function getOwnerTeamCountList(address owner) public view returns (uint[] memory) {
        uint[] memory counts = new uint[](24);
        for(uint8 i=0;i<24;i++){
            counts[i] = getOwnerTeamCount(owner,i);
        }
        return counts;
    }

    // Get the tokenIds of a specific team belonging to owner
    function getOwnerTeamTokenIds(address owner, uint8 team) public view returns (uint[] memory){
        require(team >=0 && team<= 23,"Team must be between 0 and 23");
        uint tokenCount = balanceOf(owner);
        uint teamCount = getOwnerTeamCount(owner,team);
        uint[] memory tokenIds = new uint[](teamCount);
        uint index = 0;
        for (uint i=0;i<tokenCount;i++){
            uint tokenId = tokenOfOwnerByIndex(owner, i);
            if(getTeam(tokenId)== team){
                tokenIds[index]= tokenId;
                index++;
            }
        }
        return tokenIds;
    }

    // Get all tokenIds & teams belonging to owner
    function getOwnerTokenIds(address owner) public view returns (uint[2][] memory){
        uint tokenCount = balanceOf(owner);
        uint[2][] memory tokenIds = new uint[2][](tokenCount);
        uint index = 0;
        for (uint i=0; i<tokenCount; i++){
            uint tokenId = tokenOfOwnerByIndex(owner, i);
            tokenIds[i][0] = tokenId;
            tokenIds[i][1]= _teams[tokenId];
            index++;
        }
        return tokenIds;
    }
    
    /**
     * @dev Override _beforeTokenTransfer to update counts on transfers, minting and burning.
     * @param from The address transferring the token.
     * @param to The address receiving the token.
     * @param tokenId The ID of the token being transferred.
     */
    function _beforeTokenTransfer(address from, address to, uint tokenId, uint batchSize) internal override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        uint8 team = _teams[tokenId];
        if (from != address(0)) {
            _ownerTeamCounts[from][team] -= 1;
        }
        if (to != address(0)) {
            _ownerTeamCounts[to][team] += 1;
        }
    }

    /**
     * @dev Pause the contract. Can only be called by an account with the PAUSER_ROLE.
     */
    function pause() public onlyRole(GOVERNOR_ROLE) {
        _pause();
    }

    /**
     * @dev Unpause the contract. Can only be called by an account with the PAUSER_ROLE.
     */
    function unpause() public onlyRole(GOVERNOR_ROLE) {
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721Enumerable, AccessControlEnumerable) returns (bool){
        return super.supportsInterface(interfaceId);
    }

    function _base64(bytes memory data) private pure returns (string memory) {
        bytes memory alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        bytes memory encoded = new bytes(4 * ((data.length + 2) / 3));
        for (uint256 i = 0; i < data.length; i += 3) {
            uint256 input = (uint256(uint8(data[i])) << 16) |
            (i + 1 < data.length ? uint256(uint8(data[i + 1])) << 8 : 0) |
            (i + 2 < data.length ? uint256(uint8(data[i + 2])) : 0);
            encoded[i / 3 * 4] = alphabet[input >> 18 & 0x3F];
            encoded[i / 3 * 4 + 1] = alphabet[input >> 12 & 0x3F];
            encoded[i / 3 * 4 + 2] = i + 1 < data.length ? alphabet[input >> 6 & 0x3F] : bytes1('=');
            encoded[i / 3 * 4 + 3] = i + 2 < data.length ? alphabet[input & 0x3F] : bytes1('=');
        }
        return string(encoded);
    }

    /**
     * @dev Returns the token URI for a specific token ID.
     * @param tokenId The ID of the token.
     * @return The URI of the token metadata.
     */
    function tokenURI(uint tokenId) public view override(ERC721) returns (string memory) {
        require(_exists(tokenId), "TeamCardNFT:  URI query for nonexistent token");
        uint8 team = _teams[tokenId];

        return string(
                    abi.encodePacked(
                        'data:application/json;base64,',
                        _base64(bytes(
                            string(
                                abi.encodePacked(
                                    '{"name": "', _teamNames[team],' Team Card #', tokenId.toString(), '", ',
                                    '"description": "', _teamDescs[team],' team", ',
                                    '"image": "https://euro505.io/team/', team.toString(),'.png"}'
                                )
                            )
                        ))
                    )
                );
    }
}
