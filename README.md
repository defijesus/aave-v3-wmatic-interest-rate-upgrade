This repo implements the following [AIP proposal](https://governance.aave.com/t/arc-aave-v3-polygon-wmatic-interest-rate-update/10290/3).

```
Llama presents a proposal to amend the wMATIC interest rate parameters on the Aave Polygon v3 Liquidity Pool.
```

## Getting started

### Setup environment

```sh
cp .env.example .env
```

### Build

```sh
forge build
```

### Test

```sh
forge test
```

### Deploy L2 proposal

```sh
# Deploy proposal
make deploy-<mai|frax>-<ledger|pk>
# Verify proposal
make verify-<mai|frax>
```

### Deploy L1 proposal

Make sure the referenced IPFS_HASH is properly encoded (check if the ipfs file is in json format and renders nicely on https://app.aave.com/governance/ipfs-preview/?ipfsHash=<encodedHash>).

```sh
make deploy-l1-<mai|frax>-proposal-<ledger|pk>
```

## Creating the proposal

To create a proposal you have to do two things:

1. deploy the Polygon Payload ([see MiMatic](/src/contracts/polygon/MiMaticPayload.sol))
2. create the mainnet proposal ([see DeployL1Proposal](/script/DeployL1Proposal.s.sol))

While the order of actions is important as the mainnet proposal needs the l2 payload address, both actions can be performed by different parties / addresses.
The address creating the mainnet proposal requires 80k AAVE of proposition power.

## Deployed addresses

### This repository

#### Forwarders

- [CrosschainForwarderPolygon](https://etherscan.io/address/0x158a6bc04f0828318821bae797f50b0a1299d45b#code)
- [CrosschainForwarderOptimism](https://etherscan.io/address/0x5f5c02875a8e9b5a26fbd09040abcfdeb2aa6711#code)

#### ProposalPayloads

##### Polygon

- [MiMaticPayload](https://polygonscan.com/address/0x83fba23163662149b33dbc05cf1312df6dcba72b#code)
- [FraxPayload](https://polygonscan.com/address/0xa2f3f9534e918554a9e95cfa7dc4f763d02a0859#code)

##### Optimism

- [OpPayload](https://optimistic.etherscan.io/address/0x5f5c02875a8e9b5a26fbd09040abcfdeb2aa6711#code)

### Bridges

- [PolygonBridge: FxRoot](https://etherscan.io/address/0xfe5e5d361b2ad62c541bab87c45a0b9b018389a2#code)
- [PolygonBridge: PolygonBridgeExecutor](https://polygonscan.com/address/0xdc9A35B16DB4e126cFeDC41322b3a36454B1F772#code)

- [OptimismBridge: L1CrossDomainMessenger](https://etherscan.io/address/0x25ace71c97b33cc4729cf772ae268934f7ab5fa1#readProxyContract)
- [OptimismBridge: OptimismBridgeExecutor](https://optimistic.etherscan.io/address/0x7d9103572be58ffe99dc390e8246f02dcae6f611#code)

- [ArbitrumBridge: Inbox](https://etherscan.io/address/0x4dbd4fc535ac27206064b68ffcf827b0a60bab3f#code)
- [ArtitrumBridge: ArbitrumBridgeExecutor](https://arbiscan.io/address/0x7d9103572be58ffe99dc390e8246f02dcae6f611#code)

## References

- [crosschain-bridge repository](https://github.com/aave/governance-crosschain-bridges#polygon-governance-bridge)
- [first ever polygon bridge proposal](https://github.com/pakim249CAL/Polygon-Asset-Deployment-Generic-Executor)

## Misc

- the deploy script currently requires the --legacy flag due to issues with polygon gas estimation https://github.com/ethers-io/ethers.js/issues/2828#issuecomment-1073423774
- some of the tests are currently commented out due to a bug on foundry causing public library methods to revert https://github.com/foundry-rs/foundry/issues/2549
