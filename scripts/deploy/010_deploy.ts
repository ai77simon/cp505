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
import { USDB_ADDRESS, BLAST_ENTROPY_ADDRESS, BLAST_POINTS_ADDRESS } from "../../utils/constants";
const SALE_START_BLOCK = 4432692;     //2024-06-06 12:00:00 UTC
const PLAY_START_BLOCK = 4778292;     //2024-06-14 12:00:00 UTC
const SALE_FINISH_BLOCK = 5167092;    //2024-06-23 12:00:00 UTC
const PLAY_FINISH_BLOCK = 6103092;    //2024-07-15 04:00:00 UTC
const PUBLISH_START_BLOCK = 6160692;  //2024-07-16 12:00:00 UTC
const REGULATORY_ADDRESS = "0xaBA6AaA21Df8958eb6a440398a755bAF0963a02F";      //GOVERNOR_ROLE

async function delay(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

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

  await delay(2000); // Delay 2 seconds

  //Depoly VoucherToken contract
  const voucherTokenFactory = new VoucherToken__factory(signer);
  vToken = await voucherTokenFactory.deploy();
  await vToken.deployed();
  console.log("-----vToken address=",vToken.address);
  await write(filePath,"VoucherToken.json",JSON.stringify({"address":vToken.address,"abi":VoucherToken__factory.abi}));

  await delay(2000); // Delay 2 seconds

  //epoly TeamCardNFT contract
  const teamCardNFTFactory = new TeamCardNFT__factory(signer);
  tToken = await teamCardNFTFactory.deploy(BLAST_POINTS_ADDRESS);
  await tToken.deployed();
  console.log("-----tToken address=",tToken.address);
  await write(filePath,"TeamCardNFT.json",JSON.stringify({"address":tToken.address,"abi":TeamCardNFT__factory.abi}));

  await delay(2000); // Delay 2 seconds

  //epoly BlindBoxToken contract
  const blindBoxTokenFactory = new BlindBoxToken__factory(signer);
  bToken = await blindBoxTokenFactory.deploy();
  await bToken.deployed();
  console.log("-----bToken address=",bToken.address);
  await write(filePath,"BlindBoxToken.json",JSON.stringify({"address":bToken.address,"abi":BlindBoxToken__factory.abi}));

  await delay(2000); // Delay 2 seconds

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
    paraRegulatoryAddress: REGULATORY_ADDRESS,   //GOVERNOR_ROLE
    paraBlastPointsAddress: BLAST_POINTS_ADDRESS
  };

  //Need to modify several timings to meet the testing conditions
  euroCup = await upgrades.deployProxy(euroCupFactory,[initParams]) as EuroCup;
  await euroCup.deployed();
  console.log("-----euroCup address=",euroCup.address);
  await write(filePath,"EuroCup.json",JSON.stringify({"address":euroCup.address,"abi":EuroCup__factory.abi}));

  await delay(2000); // Delay 2 seconds

  //grantRole
  console.log("-----grantRole start-----");
  await tToken.grantRole(MINTER_ROLE,euroCup.address);
  await tToken.grantRole(BURNER_ROLE,euroCup.address);
  await vToken.grantRole(MINTER_ROLE,euroCup.address);
  await vToken.grantRole(BURNER_ROLE,euroCup.address);
  await bToken.grantRole(MINTER_ROLE,euroCup.address);
  await bToken.grantRole(BURNER_ROLE,euroCup.address);
  console.log("-----grantRole end-----");
};

func.tags = ["EuroCupDeploy"];

export default func;
