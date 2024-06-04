// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
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
    }
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    uint public saleStartBlock;
    uint public playStartBlock;
    uint public saleFinishBlock;
    uint public publishStartBlock;
    uint public playFinishBlock;
    mapping(address => bool) public whiteList;

    IERC721Intact internal tToken;
    IERC20Intact internal vToken;
    IERC20Intact internal bToken;
    IERC20Metadata internal stableCoin;

    address public regulatoryAddress;
    address public blastPointsAddress;

    IEntropy public entropy;
    address public provider;
    mapping(uint64 => CacheData) private randomGeneratorMap;
    mapping(address => uint8[]) private teamCardMap;

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

    // Counter used to generate unique referral codes
    uint256 private counter;

    // Alphabet used to generate referral codes (as bytes array)
    bytes private constant ALPHABET = "ABCDEFGHIJKLMNPQRSTUVWXYZ";

    ISwapRouter public swapRouter;

    bool public getPoolFundFlag;

    // Event triggered when a new referral code is created
    event ReferralCodeCreated(address indexed user, bytes32 referralCode);
    event Buy(address indexed account, uint indexed amount,uint indexed price);
    event Open(address indexed account, uint indexed amount);
    event Synthetic(address indexed account, uint indexed amount,uint indexed price);
    event Shatter(address indexed account, uint[] indexed tokenIds);
    event GetBonus(address indexed account, uint indexed amount);
    event GetPoolFund(address indexed account, uint indexed amount);
    event GetCommission(address indexed account, uint indexed amount);
    event Generated(uint64 sequenceNumber);
    event GenerateResult(uint64 sequenceNumber, address _providerAddress, bytes32 randomNumber);

    modifier onlyWhileSale {
        if (hasRole(GOVERNOR_ROLE, msg.sender)) {
            // The GOVERNOR_ROLE role can shatter the TeamCardNFT two days in advance to establish the liquidity pool
            require(block.number >= saleStartBlock-86400 && block.number < saleFinishBlock, "EuroCup: not in sale");
        } else {
            require(block.number >= saleStartBlock && block.number < saleFinishBlock, "EuroCup: not in sale");
        }        
        _;
    }
    modifier onlyWhilePlaying {
        require(block.number >= playStartBlock && block.number < playFinishBlock, "EuroCup: not in play");
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
        ISwapRouter paraSwapRouter;
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
        entropy = IEntropy(params.paraEntropy);
        provider = entropy.getDefaultProvider();
        winner = 100;
        frozenBonusFlag = false;
        frozenCommissionFlag = false;
        counter = 1;
        swapRouter = params.paraSwapRouter;
        regulatoryAddress = params.paraRegulatoryAddress;
        blastPointsAddress = params.paraBlastPointsAddress;
        _grantRole(GOVERNOR_ROLE, regulatoryAddress);
        
        // This sets the Gas Mode for MyContract to claimable
        IBlast(0x4300000000000000000000000000000000000002).configureClaimableGas();
        IBlast(0x4300000000000000000000000000000000000002).configureGovernor(msg.sender);
        
        // BlastPoints Testnet address: 0x2fc95838c71e76ec69ff817983BFf17c710F34E0
        // BlastPoints Mainnet address: 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800
        IBlastPoints(0x2fc95838c71e76ec69ff817983BFf17c710F34E0).configurePointsOperator(blastPointsAddress);
   }

    // Buy blind box
    function buyBlindBox(uint amount,bytes32 referralCode,bytes32 userRandomNumber) external payable nonReentrant onlyWhileSale{
        // Limit the amount value
        require(amount > 0 && amount < 100, "Amount must be between 1 and 99"); 
        // Whitelist users have a starting price of 22 USDB, other users have a starting price of 30 USDB
        uint price = whiteList[msg.sender] ? 22 : 30;
        // For every 5000 blind boxes sold, the price increases by 2 USDB
        price += totalSaleBlindBox / 5000 * 2 ;
        stableCoin.transferFrom(msg.sender,address(this), amount * price * 1e18);
        address referralPersonAddress = referralCodeToAddress[referralCode];
        require(referralPersonAddress!=msg.sender,"EuroCup: Incorrect referralCode");
        if(referralPersonAddress!=address(0)){
            // Valid referral code owners will receive a 5% commission rebate
            stableCoin.transfer(referralPersonAddress,amount * price * 1e18 / 20);
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
        randomGeneratorMap[sequenceNumber] = CacheData(msg.sender,amount);
        emit Generated(sequenceNumber);
    }

    // Open blind box
    function openBlindBox() external nonReentrant{
        // Open the blind box, generate the TeamCard based on the VRF
        uint8[] memory teamCards = teamCardMap[msg.sender];
        uint teamCardsCount = teamCards.length;
        uint bTokenAmount = bToken.balanceOf(msg.sender);
        require(teamCardsCount > 0, "The number of packs must be greater than 0");
        require(teamCardsCount == bTokenAmount*5, "The packs have not all been generated yet.");        

        for(uint i=0;i<teamCards.length;i++){
            tToken.mint(msg.sender,teamCards[i]);
        }

        delete teamCardMap[msg.sender];
        bToken.burn(msg.sender,bTokenAmount);
    }

    // Synthetic blind boxes
    function synthetic(uint amount,bytes32 userRandomNumber) external payable nonReentrant onlyWhilePlaying{
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

    // Add to whitelist
    function addWhiteList(address userAddress) external onlyRole(GOVERNOR_ROLE){
        whiteList[userAddress] = true;
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
    function entropyCallback(uint64 sequenceNumber, address _providerAddress, bytes32 randomNumber) internal override {
        require(msg.sender == address(entropy), "VRF Caller is not trusted Entropy contract");
        
        CacheData storage cacheData = randomGeneratorMap[sequenceNumber];
        uint8 num = uint8(type(Team).max);
        for (uint i = 0; i < 5 * cacheData.amount; i++) {
            uint extraRandom = uint(keccak256(abi.encodePacked(block.timestamp, i)));
            uint random = uint(keccak256(abi.encodePacked(extraRandom,randomNumber))) % num;
            require(random <= 255, "random is too large for uint8");
            teamCardMap[cacheData.sender].push(uint8(random));
        }
        emit Open(cacheData.sender,cacheData.amount);
        emit GenerateResult(sequenceNumber, _providerAddress,randomNumber);
    }

    // Check if there are any unopened blind boxes that have obtained VRF
    function haveTeamCards() external view returns(bool){
        bool bolReturn = false;
        uint bTokenAmount = bToken.balanceOf(msg.sender);
        uint teamCardMapCount = teamCardMap[msg.sender].length;
        if (teamCardMapCount>0 &&  teamCardMapCount == bTokenAmount*5) {
            bolReturn = true;
        }
        return bolReturn;
    }

    /**
     * @notice Generate a referral code for the calling address.
     * @return The generated referral code.
     */
    function generateReferralCode() public returns (bytes32) {
        require(whiteList[msg.sender]||tToken.balanceOf(msg.sender)>0,"EuroCup:Unsatisfied conditions");
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
            code = generateCode(counter, block.timestamp, msg.sender);
            counter++;
        } while (referralCodeToAddress[code] != address(0)); // Ensure referral code is unique
        return code;
    }

    /**
     * @notice Internal function to generate a referral code based on inputs.
     * @param _counter The current counter value.
     * @param _timestamp The current block timestamp.
     * @param _sender The address of the message sender.
     * @return A generated referral code.
     */
    function generateCode(uint256 _counter, uint256 _timestamp, address _sender) internal pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(_counter, _timestamp, _sender));
        bytes memory code = new bytes(5);
        for (uint256 i = 0; i < 5; i++) {
            code[i] = ALPHABET[uint8(hash[i]) % 25];
        }
        return bytes32(code);
    }

    /**
     * @notice Swaps an exact input amount of tokens for a minimum output amount.
     * @dev Executes a swap on Uniswap V3 with specified parameters. The caller must have enough vTokens approved and available.
     * @param amountIn The amount of input tokens to be swapped.
     * @param amountOutMin The minimum amount of output tokens to be received.
     * @return amountOut The actual amount of output tokens received.
     */
    function swapExactInputSingle(uint256 amountIn,uint256 amountOutMin) external nonReentrant onlyWhilePlaying onlyRole(GOVERNOR_ROLE) returns (uint256 amountOut) {
        TransferHelper.safeTransferFrom(address(vToken), msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(address(vToken), address(swapRouter), amountIn);
        ISwapRouter.ExactInputSingleParams memory params =
        ISwapRouter.ExactInputSingleParams({
            tokenIn: address(vToken),
            tokenOut: address(stableCoin),
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp + 60,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });
        amountOut = swapRouter.exactInputSingle(params);
    }

}