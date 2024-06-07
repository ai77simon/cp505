//hardhat.config.ts
import * as dotenv from "dotenv";
import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";
import "hardhat-deploy";
import '@openzeppelin/hardhat-upgrades';

dotenv.config();
const BLAST_MAINNET_RPC_URL = process.env.BLAST_MAINNET_RPC_URL||"";
const BLAST_TESTNET_RPC_URL = process.env.BLAST_TESTNET_RPC_URL||"";
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY||"";
const PRIVATE_KEY = process.env.PRIVATE_KEY||"";
const ALICE_PRIVATE_KEY = process.env.ALICE_PRIVATE_KEY||"";

const config: HardhatUserConfig = {
  defaultNetwork: "blast",
  networks: {
    blast: {
      url: BLAST_MAINNET_RPC_URL,
      accounts: [PRIVATE_KEY, ALICE_PRIVATE_KEY],
      chainId: 81457
    },
    blast_sepolia: {
      url: BLAST_TESTNET_RPC_URL,
      accounts: [PRIVATE_KEY, ALICE_PRIVATE_KEY],
      chainId: 168587773
    }
  },
  etherscan: {
    apiKey: {
      blast: ETHERSCAN_API_KEY, // apiKey is not required, just set a placeholder
    },
    customChains: [
      {
        network: "blast",
        chainId: 81457,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/mainnet/evm/81457/etherscan",
          browserURL: "https://blastexplorer.io"
        }
      }
    ]
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
    deploy: "./scripts/deploy",
    deployments: "./deployments",
  },
  mocha: {
    timeout: 500000
  },
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10000
      },
    },
  },
  namedAccounts: {
    singer: 0,
    alice: 1,
    bob: 2
  },
  typechain: {
    outDir: "types",
    target: "ethers-v5",
  },
};

export default config;
