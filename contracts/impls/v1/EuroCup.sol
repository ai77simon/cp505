// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import "../../interfaces/v1/IERC721Intact.sol";
import "../../interfaces/v1/IERC20Intact.sol";
import "../../interfaces/v1/IBlast.sol";
import "../../interfaces/v1/IBlastPoints.sol";

contract EuroCup is Initializable,AccessControlEnumerableUpgradeable,ReentrancyGuardUpgradeable,PausableUpgradeable,IEntropyConsumer{
    enum Team {
        GER,  // team = 0
        SCO,  // team = 1
        HUN,  // team = 2
        SUI,  // team = 3
        ESP,  // team = 4
        CRO,  // team = 5
        ITA,  // team = 6
        ALB,  // team = 7
        SVN,  // team = 8
        DEN,  // team = 9
        SRB,  // team = 10
        ENG,  // team = 11
        NED,  // team = 12
        FRA,  // team = 13
        POL,  // team = 14
        AUT,  // team = 15
        UKR,  // team = 16
        SVK,  // team = 17
        BEL,  // team = 18
        ROU,  // team = 19
        POR,  // team = 20
        CZE,  // team = 21
        GEO,  // team = 22
        TUR   // team = 23
    }
    struct CacheData{
        address sender;
        uint amount;
        bool isGenerated;
        uint vrfTime;
    }
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    uint public saleStartBlock;
    uint public playStartBlock;
    uint public saleFinishBlock;
    uint public publishStartBlock;
    uint public playFinishBlock;

    IERC721Intact internal tToken;
    IERC20Intact internal vToken;
    IERC20Intact internal bToken;
    IERC20Metadata internal stableCoin;

    address public regulatoryAddress;
    address public blastPointsAddress;

    IEntropy public entropy;
    address public provider;
    mapping(uint64 => CacheData) private _randomGeneratorMap;
    mapping(address => uint8[24]) private _teamCardMap;

    // The maximum number of blind boxes that can be opened at one time
    uint public maxOpenBlindBoxNumber;

    uint8 public winner;
    bool public frozenBonusFlag;
    bool public frozenCommissionFlag;

    uint public totalSaleBlindBox;
    uint public totalBonus;
    uint public totalCommission;

    // Mapping from referral code to address
    mapping(bytes32 => address) public referralCodeToAddress;
    // Mapping from address to referral code
    mapping(address => bytes32) public addressToReferralCode;

    // _Counter used to generate unique referral codes
    uint private _counter;

    // Alphabet used to generate referral codes (as bytes array)
    bytes private constant ALPHABET = "ABCDEFGHIJKLMNPQRSTUVWXYZ";

    bool public getPoolFundFlag;

    // Event triggered when a new referral code is created
    event ReferralCodeCreated(address indexed user, bytes32 referralCode);
    event Buy(address indexed account, uint indexed amount,uint indexed price);
    event Open(address indexed account, uint indexed amount);
    event Synthetic(address indexed account, uint indexed amount,uint indexed price);
    event Shatter(address indexed account, uint[] indexed tokenIds);
    event GetBonus(address indexed account, uint indexed amount);
    event GetPoolUEFA(address indexed account, uint indexed amount);
    event GetPoolFund(address indexed account, uint indexed amount);
    event GetCommission(address indexed account, uint indexed amount);
    event VRFGenerated(address indexed account, uint64 sequenceNumber);
    event GenerateResult(uint64 sequenceNumber, address _providerAddress, bytes32 randomNumber);
    event BlindBoxOpened(address indexed account, uint indexed teamCardCount);
    event VRFTimeoutHandled(address indexed account, uint64 sequenceNumber, uint64 newSequenceNumber);

    modifier onlyWhileSale {
        require(block.number >= saleStartBlock && block.number < saleFinishBlock, "EuroCup: not in sale");
        _;
    }
    modifier onlyWhilePlaying {
        if (hasRole(GOVERNOR_ROLE, msg.sender)) {
            // The GOVERNOR_ROLE role can shatter the TeamCardNFT two days in advance to establish the liquidity pool
            require(block.number >= playStartBlock-43200 && block.number < playFinishBlock, "EuroCup: not in play");
        } else {
            require(block.number >= playStartBlock && block.number < playFinishBlock, "EuroCup: not in play");
        }
        _;
    }
    modifier onlyWhilePublicPeriod {
        require(block.number >= publishStartBlock && winner == 100, "EuroCup: not the period to public winner");
        _;
    }
    modifier onlyWhilePlayFinished {
        require(block.number >= playFinishBlock, "EuroCup: play not finished");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    struct InitParams {
        IERC721Intact paraTToken;
        IERC20Intact paraVToken;
        IERC20Intact paraBToken;
        IERC20Metadata paraStableCoin;
        uint paraSaleStartBlock;
        uint paraPlayStartBlock;
        uint paraSaleFinishBlock;
        uint paraPublishStartBlock;
        uint paraPlayFinishBlock;
        address paraEntropy;
        address paraRegulatoryAddress;
        address paraBlastPointsAddress;
    }

    function initialize(InitParams memory params) external initializer{
        __AccessControlEnumerable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        tToken = params.paraTToken;
        vToken = params.paraVToken;
        bToken = params.paraBToken;
        stableCoin = params.paraStableCoin;
        saleStartBlock = params.paraSaleStartBlock;
        playStartBlock = params.paraPlayStartBlock;
        saleFinishBlock = params.paraSaleFinishBlock;
        publishStartBlock = params.paraPublishStartBlock;
        playFinishBlock = params.paraPlayFinishBlock;
        maxOpenBlindBoxNumber = 20;    // The maximum number of TeamCardNFT that can be generated at one time.
        entropy = IEntropy(params.paraEntropy);
        provider = entropy.getDefaultProvider();
        winner = 100;
        frozenBonusFlag = false;
        frozenCommissionFlag = false;
        _counter = 1;
        regulatoryAddress = params.paraRegulatoryAddress;
        blastPointsAddress = params.paraBlastPointsAddress;
        _grantRole(GOVERNOR_ROLE, regulatoryAddress);
        
        // This sets the Gas Mode for MyContract to claimable
        IBlast(0x4300000000000000000000000000000000000002).configureClaimableGas();
        IBlast(0x4300000000000000000000000000000000000002).configureGovernor(msg.sender);
        
        // BlastPoints Testnet address: 0x2fc95838c71e76ec69ff817983BFf17c710F34E0
        // BlastPoints Mainnet address: 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800
        IBlastPoints(0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800).configurePointsOperator(blastPointsAddress);
   }

    // Buy blind box
    function buyBlindBox(uint amount,bytes32 referralCode,bytes32 userRandomNumber) external payable nonReentrant onlyWhileSale{
        // Limit the amount value
        require(amount > 0 && amount < 100, "Amount must be between 1 and 99"); 
        // starting price is 30 USDB
        uint price = 30;
        // For every 5000 blind boxes sold, the price increases by 2 USDB
        price += totalSaleBlindBox / 5000 * 2 ;
        stableCoin.transferFrom(msg.sender,address(this), amount * price * 1e18);
        address referralPersonAddress = referralCodeToAddress[referralCode];
        require(referralPersonAddress!=msg.sender,"EuroCup: Incorrect referralCode");
        if(referralPersonAddress!=address(0)){
            // Valid referral code owners will receive a 10% commission rebate
            stableCoin.transfer(referralPersonAddress,amount * price * 1e18 / 10);
        }
        bToken.mint(msg.sender,amount);
        totalSaleBlindBox += amount;
        // Asynchronous call to get VRF, Confirming the VRF also confirms the team attributes in the blind box
        callVRF(amount,userRandomNumber);
        emit Buy(msg.sender,amount,price);
    }

    // Asynchronous call to get VRF
    function callVRF(uint amount,bytes32 userRandomNumber) internal{
        // Limit the amount value
        require(amount > 0 && amount < 100, "Amount must be between 1 and 99");
        uint128 requestFee = entropy.getFee(provider);
        if (msg.value < requestFee) revert("not enough fees");
        uint64 sequenceNumber = entropy.requestWithCallback{ value: requestFee }(provider, userRandomNumber);
        require(sequenceNumber > 0, "Invalid sequence number");
        _randomGeneratorMap[sequenceNumber] = CacheData(msg.sender,amount,false,block.timestamp);
        emit VRFGenerated(msg.sender, sequenceNumber);
    }

    // Handle VRF timeout more than 1 day
    function handleVRFTimeout(uint64 sequenceNumber) external onlyRole(GOVERNOR_ROLE) {
        CacheData storage cacheData = _randomGeneratorMap[sequenceNumber];
        uint timeoutPeriod = 86400;   // 1 day
        require(block.timestamp > cacheData.vrfTime + timeoutPeriod, "Request has not timed out yet");
        require(!cacheData.isGenerated, "Random number already generated");

        address user = cacheData.sender;
        uint amount = cacheData.amount;
        delete _randomGeneratorMap[sequenceNumber];

        bytes32 newUserRandomNumber = keccak256(abi.encodePacked(sequenceNumber, block.timestamp, user));
        uint64 newSequenceNumber = entropy.requestWithCallback{ value: entropy.getFee(provider) }(provider, newUserRandomNumber);
        require(sequenceNumber > 0, "Invalid sequence number");
        _randomGeneratorMap[newSequenceNumber] = CacheData(user, amount, false, block.timestamp);

        emit VRFTimeoutHandled(user, sequenceNumber, newSequenceNumber);
    }


    // Open blind box
    function openBlindBox() external nonReentrant{
        // Open the blind box, generate the TeamCard based on the VRF
        uint teamCardsCount = _getTeamCardCount(msg.sender);
        require(teamCardsCount > 0, "The number of pack must be greater than 0");

        uint bTokenAmount = bToken.balanceOf(msg.sender);        
        require(teamCardsCount == bTokenAmount*5, "The packs have not all been generated yet");
        
        // The maximum number of TeamCardNFT that can be generated at one time
        uint maxGeneTCardNumber = maxOpenBlindBoxNumber * 5;
        uint geneTCardCount = 0;
        for (uint8 i=0; i<24; i++) {
            uint teamCount = _teamCardMap[msg.sender][i];
            for (uint j=0; j<teamCount && geneTCardCount<maxGeneTCardNumber; j++) {
                tToken.mint(msg.sender, i);
                _teamCardMap[msg.sender][i]--;
                geneTCardCount++;
            }
        }

        if (teamCardsCount <= maxGeneTCardNumber) {
            delete _teamCardMap[msg.sender];
        }

        bToken.burn(msg.sender, geneTCardCount/5);

        emit BlindBoxOpened(msg.sender, geneTCardCount);
    }

    // Synthetic blind boxes
    function synthetic(uint amount,bytes32 userRandomNumber) external payable nonReentrant onlyWhilePlaying{
        require(block.number > playStartBlock, "the PlayStartBlock must larger than block.num");
        // Synthetic blind boxes, merging one blind box requires an additional 60 UEFA per hour
        uint price = 50000 + (block.number - playStartBlock) / 1800 * 60 ;
        vToken.burn(msg.sender,amount * price * 1e18);
        bToken.mint(msg.sender,amount);

        // Asynchronous call to get VRF, Confirming the VRF also confirms the team attributes in the blind box
        callVRF(amount,userRandomNumber);
        emit Synthetic(msg.sender,amount,price);
    }

    // Shatter the blind boxes
    function shatter(uint[] memory tokenIds) external nonReentrant onlyWhilePlaying{
        for (uint i = 0; i < tokenIds.length; i++) {
            require(tToken.ownerOf(tokenIds[i]) == msg.sender, "Sender does not own all tokenIds");
        }

        // Consume the TeamCardNFT corresponding to the tokenIds
        tToken.burnBatch(tokenIds);
        uint256 totalAmount = tokenIds.length;
        // Shattering one blind box, the user will receive 8000 UEFA
        vToken.mint(msg.sender,totalAmount * 8000 * 1e18);
        // Shattering one blind box, the prize pool will receive 1000 UEFA
        vToken.mint(address(this),totalAmount * 1000 * 1e18);
        emit Shatter(msg.sender,tokenIds);
    }

    // The competition ends, receive the prize
    // The owner of the champion team's CARD will receive 90% of the prize pool, and the administrator will receive 10% of the prize pool
    function getBonus() external nonReentrant onlyWhilePlayFinished{
        require(winner != 100,"not set winner");
        if(!frozenBonusFlag){
            totalBonus = stableCoin.balanceOf(address(this)) * 9 / 10;
            totalCommission = stableCoin.balanceOf(address(this)) * 1 / 10;
            frozenBonusFlag = true;
        }
        uint amount = tToken.getOwnerTeamCount(msg.sender,winner);
        require(amount > 0,"amount must greater than zero");
        uint totalSupply = tToken.getTeamCount(winner);
        uint award = totalBonus * amount / totalSupply;
        stableCoin.transfer(msg.sender,award);
        totalBonus -= award;
        for(uint i=0;i<amount;i++){
            uint tokenId = tToken.tokenOfOwnerByIndex(msg.sender,i);
            tToken.burn(tokenId);
        }        
        emit GetBonus(msg.sender,award);
    }

    // Get the UEFA from the prize pool, exchange it for USDB in the trading market, and then deposit it back into the prize pool
    function getPoolUEFA() external nonReentrant onlyRole(GOVERNOR_ROLE){
        uint totalUEFA = vToken.balanceOf(address(this));
        vToken.transfer(msg.sender,totalUEFA);
        emit GetPoolUEFA(msg.sender,totalUEFA);
    }

    // A one-time extraction of 10% of the USDB will be allocated to the liquidity pool
    function getPoolFund() external nonReentrant onlyWhilePlaying onlyRole(GOVERNOR_ROLE){
        if(!getPoolFundFlag){
            uint totalFund = stableCoin.balanceOf(address(this)) * 1 / 10;
            getPoolFundFlag = true;
            stableCoin.transfer(msg.sender,totalFund);
            emit GetPoolFund(msg.sender,totalFund);
        }
    }

    // The management account advances the final prize
    function getCommission() external nonReentrant onlyWhilePlayFinished onlyRole(GOVERNOR_ROLE){
        if(!frozenBonusFlag){
            totalBonus = stableCoin.balanceOf(address(this)) * 9 / 10;
            totalCommission = stableCoin.balanceOf(address(this)) * 1 / 10;
            frozenBonusFlag = true;
        }
        if(!frozenCommissionFlag){            
            stableCoin.transfer(msg.sender,totalCommission);
            frozenCommissionFlag = true;
            emit GetCommission(msg.sender,totalCommission);
        }
    }

    // 设置冠军队
    function setWinner(Team winner_) external onlyWhilePublicPeriod onlyRole(GOVERNOR_ROLE){
        winner = uint8(winner_);
    }

    function pause() external onlyRole(GOVERNOR_ROLE){
        _pause();
    }

    function unpause() external onlyRole(GOVERNOR_ROLE){
        _unpause();
    }

    function getEntropy() internal view override returns (address){
        return address(entropy);
    }

    // This function is called by the Entropy contract, Callback function to handle the generated random number
    function entropyCallback(uint64 sequenceNumber, address _providerAddress, bytes32 randomNumber) internal override{
        // require(_providerAddress == provider, "Invalid provider address");
        CacheData memory cacheData = _randomGeneratorMap[sequenceNumber];
        require(cacheData.sender!=address(0) && cacheData.isGenerated==false, "No data available to process");

        if (_teamCardMap[cacheData.sender].length == 0) {
            // Mapping does not exist, initialize it
            _teamCardMap[cacheData.sender] = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0)];
        }

        for (uint i = 0; i < 5 * cacheData.amount; i++) {
            uint extraRandom = uint(keccak256(abi.encodePacked(block.timestamp, i)));
            uint randomTeam = uint(keccak256(abi.encodePacked(extraRandom, randomNumber))) % 24;
            _teamCardMap[cacheData.sender][randomTeam]++;
        }
        _randomGeneratorMap[sequenceNumber].isGenerated = true;
        emit Open(cacheData.sender, cacheData.amount);
        emit GenerateResult(sequenceNumber, _providerAddress, randomNumber);
    }

    function getTeamCardCount(address checkAddress) public view returns (uint) {
        return _getTeamCardCount(checkAddress);
    }

    // return sum for _teamCardMap[checkAddress]
    function _getTeamCardCount(address checkAddress) internal view returns (uint){
        uint teamCardSum = 0;
        for (uint i=0; i<24; i++) {
            teamCardSum += _teamCardMap[checkAddress][i];
        }
        return teamCardSum;
    }

    // Check if there are any unopened blind boxes that have obtained VRF
    function haveTeamCards() external view returns(bool){
        bool bolReturn = false;
        uint bTokenAmount = bToken.balanceOf(msg.sender);
        uint teamCardsCount = _getTeamCardCount(msg.sender);

        if (teamCardsCount == 0 || bTokenAmount == 0) {
            return false;
        }
        
        if (teamCardsCount == bTokenAmount*5) {
            bolReturn = true;
        }
        return bolReturn;
    }

    /**
     * @notice Generate a referral code for the calling address.
     * @return The generated referral code.
     */
    function generateReferralCode() public returns (bytes32) {
        require(bToken.balanceOf(msg.sender)>0||tToken.balanceOf(msg.sender)>0,"EuroCup:Unsatisfied conditions");
        address user = msg.sender;
        require(addressToReferralCode[user] == bytes32(0), "Referral code already exists for this address");
        // Generate unique referral code
        bytes32 referralCode = generateUniqueCode(); // Map the referral code to the address
        referralCodeToAddress[referralCode] = user;
        addressToReferralCode[user] = referralCode;
        emit ReferralCodeCreated(user, referralCode);
        return referralCode;
    }

    /**
     * @notice Internal function to generate a unique referral code.
     * @return A unique referral code.
     */
    function generateUniqueCode() internal returns (bytes32) {
        bytes32 code;
        do {
            code = generateCode(_counter, block.timestamp, msg.sender);
            _counter++;
        } while (referralCodeToAddress[code] != address(0)); // Ensure referral code is unique
        return code;
    }

    /**
     * @notice Internal function to generate a referral code based on inputs.
     * @param _paraCounter The current counter value.
     * @param _timestamp The current block timestamp.
     * @param _sender The address of the message sender.
     * @return A generated referral code.
     */
    function generateCode(uint256 _paraCounter, uint256 _timestamp, address _sender) internal pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(_paraCounter, _timestamp, _sender));
        bytes memory code = new bytes(5);
        for (uint256 i = 0; i < 5; i++) {
            code[i] = ALPHABET[uint8(hash[i]) % 25];
        }
        return bytes32(code);
    }
}