import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import {ethers, upgrades} from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import {write} from "../../utils/io";
import {
  BlindBoxToken,
  BlindBoxToken__factory, EuroCup, EuroCup__factory,
  TeamCardNFT, TeamCardNFT__factory,
  VoucherToken, VoucherToken__factory
} from "../../types";
import { USDB_ADDRESS, SWAP_ROUTER, BLAST_ENTROPY_ADDRESS } from "../../utils/constants";
const SALE_START_BLOCK = 6330000;     //Need to change to 4259892, 2024-06-02 12:00:00 UTC
const PLAY_START_BLOCK = 6330000;     //Need to change to 4605492, 2024-06-10 12:00:00 UTC
const SALE_FINISH_BLOCK = 6500000;    //Need to change to 5433492, 2024-06-29 16:00:00 UTC
const PUBLISH_START_BLOCK = 6330000;  //Need to change to 6081492, 2024-07-15 00:00:00 UTC
const PLAY_FINISH_BLOCK = 6500000;    //Need to change to 6086892, 2024-07-14 19:00:00 UTC
const REGULATORY_ADDRESS = "0xbC748b2bE638FE252DcBEf668D039cFF60f36014";
const BLAST_POINTS_ADDRESS = "0xbC748b2bE638FE252DcBEf668D039cFF60f36014";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const filePath = hre.config.paths.deployments+"\\"+hre.network.name;
  await write(filePath,".chainId",await hre.getChainId());
  let signer: SignerWithAddress;
  [signer] = await ethers.getSigners();
  console.log("-----singer address=",signer.address);
  let vToken: VoucherToken;
  let tToken: TeamCardNFT;
  let bToken: BlindBoxToken;
  let euroCup: EuroCup;
  let MINTER_ROLE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MINTER_ROLE"));
  let BURNER_ROLE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("BURNER_ROLE"));
  //Depoly VoucherToken contract
  const voucherTokenFactory = new VoucherToken__factory(signer);
  vToken = await voucherTokenFactory.deploy();
  await vToken.deployed();
  console.log("-----vToken address=",vToken.address);
  await write(filePath,"VoucherToken.json",JSON.stringify({"address":vToken.address,"abi":VoucherToken__factory.abi}));
  //epoly TeamCardNFT contract
  const teamCardNFTFactory = new TeamCardNFT__factory(signer);
  tToken = await teamCardNFTFactory.deploy(BLAST_POINTS_ADDRESS);
  await tToken.deployed();
  console.log("-----tToken address=",tToken.address);
  await write(filePath,"TeamCardNFT.json",JSON.stringify({"address":tToken.address,"abi":TeamCardNFT__factory.abi}));
  //epoly BlindBoxToken contract
  const blindBoxTokenFactory = new BlindBoxToken__factory(signer);
  bToken = await blindBoxTokenFactory.deploy();
  await bToken.deployed();
  console.log("-----bToken address=",bToken.address);
  await write(filePath,"BlindBoxToken.json",JSON.stringify({"address":bToken.address,"abi":BlindBoxToken__factory.abi}));
  //epoly EuroCup contract
  const euroCupFactory = new EuroCup__factory(signer);

  const initParams = {
    paraTToken: tToken.address,
    paraVToken: vToken.address,
    paraBToken: bToken.address,
    paraStableCoin: USDB_ADDRESS,
    paraSaleStartBlock: SALE_START_BLOCK,
    paraPlayStartBlock: PLAY_START_BLOCK,
    paraSaleFinishBlock: SALE_FINISH_BLOCK,
    paraPublishStartBlock: PUBLISH_START_BLOCK,
    paraPlayFinishBlock: PLAY_FINISH_BLOCK,
    paraEntropy: BLAST_ENTROPY_ADDRESS,
    paraSwapRouter: SWAP_ROUTER,
    paraRegulatoryAddress: REGULATORY_ADDRESS,
    paraBlastPointsAddress: BLAST_POINTS_ADDRESS
  };

  //Need to modify several timings to meet the testing conditions
  euroCup = await upgrades.deployProxy(euroCupFactory,[initParams]) as EuroCup;
  await euroCup.deployed();
  console.log("-----euroCup address=",euroCup.address);
  await write(filePath,"EuroCup.json",JSON.stringify({"address":euroCup.address,"abi":EuroCup__factory.abi}));
  //grantRole
  await tToken.grantRole(MINTER_ROLE,euroCup.address);
  await tToken.grantRole(BURNER_ROLE,euroCup.address);
  await vToken.grantRole(MINTER_ROLE,euroCup.address);
  await vToken.grantRole(BURNER_ROLE,euroCup.address);
  await bToken.grantRole(MINTER_ROLE,euroCup.address);
  await bToken.grantRole(BURNER_ROLE,euroCup.address);
};

func.tags = ["EuroCupDeploy"];

export default func;
