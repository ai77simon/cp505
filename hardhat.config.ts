//hardhat.config.ts
import * as dotenv from "dotenv";
import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";
import "hardhat-deploy";
import '@openzeppelin/hardhat-upgrades';
import '@nomiclabs/hardhat-etherscan';

dotenv.config();
const BLAST_MAINNET_RPC_URL = process.env.BLAST_MAINNET_RPC_URL||"";
const BLAST_TESTNET_RPC_URL = process.env.BLAST_TESTNET_RPC_URL||"";

const PRIVATE_KEY = process.env.PRIVATE_KEY||"";
const ALICE_PRIVATE_KEY = process.env.ALICE_PRIVATE_KEY||"";

const config: HardhatUserConfig = {
  defaultNetwork: "blast_sepolia",
  networks: {
    hardhat: {
      chainId: 8545
    },
    blast: {
      url: BLAST_MAINNET_RPC_URL,
      accounts: [PRIVATE_KEY,ALICE_PRIVATE_KEY],
      chainId: 81457
    },
    blast_sepolia: {
      url: BLAST_TESTNET_RPC_URL,
      accounts: [PRIVATE_KEY,ALICE_PRIVATE_KEY],
      chainId: 168587773
    }
  },
  etherscan: {
    apiKey: {
      blast_sepolia: "blast_sepolia", // apiKey is not required, just set a placeholder
    },
    customChains: [
      {
        network: "blast_sepolia",
        chainId: 168587773,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/testnet/evm/168587773/etherscan",
          browserURL: "https://sepolia.blastexplorer.io"
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
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
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