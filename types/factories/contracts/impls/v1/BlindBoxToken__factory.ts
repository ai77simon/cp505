/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../../common";
import type {
  BlindBoxToken,
  BlindBoxTokenInterface,
} from "../../../../contracts/impls/v1/BlindBoxToken";

const _abi = [
  {
    inputs: [],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Approval",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "Burned",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "Minted",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "Paused",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "previousAdminRole",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "newAdminRole",
        type: "bytes32",
      },
    ],
    name: "RoleAdminChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
    ],
    name: "RoleGranted",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
    ],
    name: "RoleRevoked",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Transfer",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "Unpaused",
    type: "event",
  },
  {
    inputs: [],
    name: "BURNER_ROLE",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "DEFAULT_ADMIN_ROLE",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "GOVERNOR_ROLE",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "MINTER_ROLE",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
    ],
    name: "allowance",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "approve",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "balanceOf",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "burn",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "decimals",
    outputs: [
      {
        internalType: "uint8",
        name: "",
        type: "uint8",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "subtractedValue",
        type: "uint256",
      },
    ],
    name: "decreaseAllowance",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
    ],
    name: "getRoleAdmin",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "uint256",
        name: "index",
        type: "uint256",
      },
    ],
    name: "getRoleMember",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
    ],
    name: "getRoleMemberCount",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "grantRole",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "hasRole",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "addedValue",
        type: "uint256",
      },
    ],
    name: "increaseAllowance",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "mint",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "pause",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "paused",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "renounceRole",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "revokeRole",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes4",
        name: "interfaceId",
        type: "bytes4",
      },
    ],
    name: "supportsInterface",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "symbol",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "totalSupply",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "transfer",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
      {
        internalType: "address",
        name: "",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "transferFrom",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [],
    name: "unpause",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

const _bytecode =
  "0x60806040523480156200001157600080fd5b5060405180604001604052806008815260200167084d8d2dcc884def60c31b81525060405180604001604052806004815260200163084849eb60e31b81525081600590816200006191906200030c565b5060066200007082826200030c565b50506007805460ff19169055506200008a600033620000c7565b620000a560008051602062001ab183398151915233620000c7565b620000c160008051602062001ab183398151915260006200010a565b620003d8565b620000de82826200015560201b620009b01760201c565b60008281526001602090815260409091206200010591839062000a34620001f6821b17901c565b505050565b600082815260208190526040808220600101805490849055905190918391839186917fbd79b86ffe0ab8e8776151514217cd7cacd52c909f66475c3af44e129f0b00ff9190a4505050565b6000828152602081815260408083206001600160a01b038516845290915290205460ff16620001f2576000828152602081815260408083206001600160a01b03851684529091529020805460ff19166001179055620001b13390565b6001600160a01b0316816001600160a01b0316837f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a45b5050565b60006200020d836001600160a01b03841662000216565b90505b92915050565b60008181526001830160205260408120546200025f5750815460018181018455600084815260208082209093018490558454848252828601909352604090209190915562000210565b50600062000210565b634e487b7160e01b600052604160045260246000fd5b600181811c908216806200029357607f821691505b602082108103620002b457634e487b7160e01b600052602260045260246000fd5b50919050565b601f8211156200010557600081815260208120601f850160051c81016020861015620002e35750805b601f850160051c820191505b818110156200030457828155600101620002ef565b505050505050565b81516001600160401b0381111562000328576200032862000268565b62000340816200033984546200027e565b84620002ba565b602080601f8311600181146200037857600084156200035f5750858301515b600019600386901b1c1916600185901b17855562000304565b600085815260208120601f198616915b82811015620003a95788860151825594840194600190910190840162000388565b5085821015620003c85787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b6116c980620003e86000396000f3fe608060405234801561001057600080fd5b50600436106101c45760003560e01c806370a08231116100f9578063a457c2d711610097578063ccc5749011610071578063ccc57490146103be578063d5391393146103e5578063d547741f1461040c578063dd62ed3e1461041f57600080fd5b8063a457c2d71461038a578063a9059cbb1461039d578063ca15c873146103ab57600080fd5b806391d14854116100d357806391d148541461035457806395d89b41146103675780639dc29fac1461036f578063a217fddf1461038257600080fd5b806370a08231146102f85780638456cb59146103215780639010d07c1461032957600080fd5b80632f2ff15d11610166578063395093511161014057806339509351146102bf5780633f4ba83a146102d257806340c10f19146102da5780635c975abb146102ed57600080fd5b80632f2ff15d14610288578063313ce5671461029d57806336568abe146102ac57600080fd5b806318160ddd116101a257806318160ddd1461021957806323b872dd1461022b578063248a9ca31461023e578063282c51f31461026157600080fd5b806301ffc9a7146101c957806306fdde03146101f1578063095ea7b314610206575b600080fd5b6101dc6101d7366004611389565b610432565b60405190151581526020015b60405180910390f35b6101f961045d565b6040516101e891906113d7565b6101dc610214366004611426565b6104ef565b6004545b6040519081526020016101e8565b6101dc610239366004611450565b610507565b61021d61024c36600461148c565b60009081526020819052604090206001015490565b61021d7f3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a84881565b61029b6102963660046114a5565b610566565b005b604051600081526020016101e8565b61029b6102ba3660046114a5565b610590565b6101dc6102cd366004611426565b61060e565b6101dc610630565b6101dc6102e8366004611426565b61066c565b60075460ff166101dc565b61021d6103063660046114d1565b6001600160a01b031660009081526002602052604090205490565b6101dc610753565b61033c6103373660046114ec565b610787565b6040516001600160a01b0390911681526020016101e8565b6101dc6103623660046114a5565b6107a6565b6101f96107cf565b6101dc61037d366004611426565b6107de565b61021d600081565b6101dc610398366004611426565b6108c3565b6101dc610239366004611426565b61021d6103b936600461148c565b610949565b61021d7f7935bd0ae54bc31f548c14dba4d37c5c64b3f8ca900cb468fb8abd54d5894f5581565b61021d7f9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a681565b61029b61041a3660046114a5565b610960565b61021d61042d36600461150e565b610985565b60006001600160e01b03198216635a05180f60e01b1480610457575061045782610a49565b92915050565b60606005805461046c90611538565b80601f016020809104026020016040519081016040528092919081815260200182805461049890611538565b80156104e55780601f106104ba576101008083540402835291602001916104e5565b820191906000526020600020905b8154815290600101906020018083116104c857829003601f168201915b5050505050905090565b6000336104fd818585610a7e565b5060019392505050565b60405162461bcd60e51b815260206004820152602660248201527f426c696e64426f78546f6b656e3a20746f6b656e207472616e736665722064696044820152651cd8589b195960d21b60648201526000906084015b60405180910390fd5b60008281526020819052604090206001015461058181610ba2565b61058b8383610baf565b505050565b6001600160a01b03811633146106005760405162461bcd60e51b815260206004820152602f60248201527f416363657373436f6e74726f6c3a2063616e206f6e6c792072656e6f756e636560448201526e103937b632b9903337b91039b2b63360891b606482015260840161055d565b61060a8282610bd1565b5050565b6000336104fd8185856106218383610985565b61062b9190611588565b610a7e565b60007f7935bd0ae54bc31f548c14dba4d37c5c64b3f8ca900cb468fb8abd54d5894f5561065c81610ba2565b610664610bf3565b600191505090565b6000610676610c45565b7f9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a66106a081610ba2565b600083116107075760405162461bcd60e51b815260206004820152602e60248201527f45524332303a206d696e7420616d6f756e742073686f756c642062652067726560448201526d61746572207468616e207a65726f60901b606482015260840161055d565b6107118484610c8d565b60405183906001600160a01b0386169033907f9d228d69b5fdb8d273a2336f8fb8612d039631024ea9bf09c424a9503aa078f090600090a45060019392505050565b60007f7935bd0ae54bc31f548c14dba4d37c5c64b3f8ca900cb468fb8abd54d5894f5561077f81610ba2565b610664610d5a565b600082815260016020526040812061079f9083610d97565b9392505050565b6000918252602082815260408084206001600160a01b0393909316845291905290205460ff1690565b60606006805461046c90611538565b60006107e8610c45565b7f3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a84861081281610ba2565b600083116108795760405162461bcd60e51b815260206004820152602e60248201527f45524332303a206275726e20616d6f756e742073686f756c642062652067726560448201526d61746572207468616e207a65726f60901b606482015260840161055d565b6108838484610da3565b60405183906001600160a01b038616907f696de425f79f4a40bc6d2122ca50507f0efbeabbff86a84871b7196ab8ea8df790600090a35060019392505050565b600033816108d18286610985565b9050838110156109315760405162461bcd60e51b815260206004820152602560248201527f45524332303a2064656372656173656420616c6c6f77616e63652062656c6f77604482015264207a65726f60d81b606482015260840161055d565b61093e8286868403610a7e565b506001949350505050565b600081815260016020526040812061045790610ee3565b60008281526020819052604090206001015461097b81610ba2565b61058b8383610bd1565b6001600160a01b03918216600090815260036020908152604080832093909416825291909152205490565b6109ba82826107a6565b61060a576000828152602081815260408083206001600160a01b03851684529091529020805460ff191660011790556109f03390565b6001600160a01b0316816001600160a01b0316837f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a45050565b600061079f836001600160a01b038416610eed565b60006001600160e01b03198216637965db0b60e01b148061045757506301ffc9a760e01b6001600160e01b0319831614610457565b6001600160a01b038316610ae05760405162461bcd60e51b8152602060048201526024808201527f45524332303a20617070726f76652066726f6d20746865207a65726f206164646044820152637265737360e01b606482015260840161055d565b6001600160a01b038216610b415760405162461bcd60e51b815260206004820152602260248201527f45524332303a20617070726f766520746f20746865207a65726f206164647265604482015261737360f01b606482015260840161055d565b6001600160a01b0383811660008181526003602090815260408083209487168084529482529182902085905590518481527f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925910160405180910390a3505050565b610bac8133610f3c565b50565b610bb982826109b0565b600082815260016020526040902061058b9082610a34565b610bdb8282610f95565b600082815260016020526040902061058b9082610ffa565b610bfb61100f565b6007805460ff191690557f5db9ee0a495bf2e6ff9c91a7834c1ba4fdd244a5e8aa4e537bd38aeae4b073aa335b6040516001600160a01b03909116815260200160405180910390a1565b60075460ff1615610c8b5760405162461bcd60e51b815260206004820152601060248201526f14185d5cd8589b194e881c185d5cd95960821b604482015260640161055d565b565b6001600160a01b038216610ce35760405162461bcd60e51b815260206004820152601f60248201527f45524332303a206d696e7420746f20746865207a65726f206164647265737300604482015260640161055d565b610cef60008383611058565b8060046000828254610d019190611588565b90915550506001600160a01b0382166000818152600260209081526040808320805486019055518481527fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef910160405180910390a35050565b610d62610c45565b6007805460ff191660011790557f62e78cea01bee320cd4e420270b5ea74000d11b0c9f74754ebdbfc544b05a258610c283390565b600061079f83836110be565b6001600160a01b038216610e035760405162461bcd60e51b815260206004820152602160248201527f45524332303a206275726e2066726f6d20746865207a65726f206164647265736044820152607360f81b606482015260840161055d565b610e0f82600083611058565b6001600160a01b03821660009081526002602052604090205481811015610e835760405162461bcd60e51b815260206004820152602260248201527f45524332303a206275726e20616d6f756e7420657863656564732062616c616e604482015261636560f01b606482015260840161055d565b6001600160a01b03831660008181526002602090815260408083208686039055600480548790039055518581529192917fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef910160405180910390a3505050565b6000610457825490565b6000818152600183016020526040812054610f3457508154600181810184556000848152602080822090930184905584548482528286019093526040902091909155610457565b506000610457565b610f4682826107a6565b61060a57610f53816110e8565b610f5e8360206110fa565b604051602001610f6f92919061159b565b60408051601f198184030181529082905262461bcd60e51b825261055d916004016113d7565b610f9f82826107a6565b1561060a576000828152602081815260408083206001600160a01b0385168085529252808320805460ff1916905551339285917ff6391f5c32d9c69d2a47ea670b442974b53935d1edc7fd64eb21e047a839171b9190a45050565b600061079f836001600160a01b038416611296565b60075460ff16610c8b5760405162461bcd60e51b815260206004820152601460248201527314185d5cd8589b194e881b9bdd081c185d5cd95960621b604482015260640161055d565b60075460ff161561058b5760405162461bcd60e51b815260206004820152602a60248201527f45524332305061757361626c653a20746f6b656e207472616e736665722077686044820152691a5b19481c185d5cd95960b21b606482015260840161055d565b60008260000182815481106110d5576110d5611610565b9060005260206000200154905092915050565b60606104576001600160a01b03831660145b60606000611109836002611626565b611114906002611588565b67ffffffffffffffff81111561112c5761112c61163d565b6040519080825280601f01601f191660200182016040528015611156576020820181803683370190505b509050600360fc1b8160008151811061117157611171611610565b60200101906001600160f81b031916908160001a905350600f60fb1b816001815181106111a0576111a0611610565b60200101906001600160f81b031916908160001a90535060006111c4846002611626565b6111cf906001611588565b90505b6001811115611247576f181899199a1a9b1b9c1cb0b131b232b360811b85600f166010811061120357611203611610565b1a60f81b82828151811061121957611219611610565b60200101906001600160f81b031916908160001a90535060049490941c9361124081611653565b90506111d2565b50831561079f5760405162461bcd60e51b815260206004820181905260248201527f537472696e67733a20686578206c656e67746820696e73756666696369656e74604482015260640161055d565b6000818152600183016020526040812054801561137f5760006112ba60018361166a565b85549091506000906112ce9060019061166a565b90508181146113335760008660000182815481106112ee576112ee611610565b906000526020600020015490508087600001848154811061131157611311611610565b6000918252602080832090910192909255918252600188019052604090208390555b85548690806113445761134461167d565b600190038181906000526020600020016000905590558560010160008681526020019081526020016000206000905560019350505050610457565b6000915050610457565b60006020828403121561139b57600080fd5b81356001600160e01b03198116811461079f57600080fd5b60005b838110156113ce5781810151838201526020016113b6565b50506000910152565b60208152600082518060208401526113f68160408501602087016113b3565b601f01601f19169190910160400192915050565b80356001600160a01b038116811461142157600080fd5b919050565b6000806040838503121561143957600080fd5b6114428361140a565b946020939093013593505050565b60008060006060848603121561146557600080fd5b61146e8461140a565b925061147c6020850161140a565b9150604084013590509250925092565b60006020828403121561149e57600080fd5b5035919050565b600080604083850312156114b857600080fd5b823591506114c86020840161140a565b90509250929050565b6000602082840312156114e357600080fd5b61079f8261140a565b600080604083850312156114ff57600080fd5b50508035926020909101359150565b6000806040838503121561152157600080fd5b61152a8361140a565b91506114c86020840161140a565b600181811c9082168061154c57607f821691505b60208210810361156c57634e487b7160e01b600052602260045260246000fd5b50919050565b634e487b7160e01b600052601160045260246000fd5b8082018082111561045757610457611572565b7f416363657373436f6e74726f6c3a206163636f756e74200000000000000000008152600083516115d38160178501602088016113b3565b7001034b99036b4b9b9b4b733903937b6329607d1b60179184019182015283516116048160288401602088016113b3565b01602801949350505050565b634e487b7160e01b600052603260045260246000fd5b808202811582820484141761045757610457611572565b634e487b7160e01b600052604160045260246000fd5b60008161166257611662611572565b506000190190565b8181038181111561045757610457611572565b634e487b7160e01b600052603160045260246000fdfea26469706673582212203cf6965d5cfe71fae08ec5342cb0b81e76813bfe461cd5fb985b0e301f30912d64736f6c634300081200337935bd0ae54bc31f548c14dba4d37c5c64b3f8ca900cb468fb8abd54d5894f55";

type BlindBoxTokenConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: BlindBoxTokenConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class BlindBoxToken__factory extends ContractFactory {
  constructor(...args: BlindBoxTokenConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<BlindBoxToken> {
    return super.deploy(overrides || {}) as Promise<BlindBoxToken>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): BlindBoxToken {
    return super.attach(address) as BlindBoxToken;
  }
  override connect(signer: Signer): BlindBoxToken__factory {
    return super.connect(signer) as BlindBoxToken__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): BlindBoxTokenInterface {
    return new utils.Interface(_abi) as BlindBoxTokenInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): BlindBoxToken {
    return new Contract(address, _abi, signerOrProvider) as BlindBoxToken;
  }
}
