// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon} from 'aave-address-book/AaveV3Polygon.sol';
import {IPoolConfigurator} from 'aave-address-book/AaveV3.sol';
import {IProposalGenericExecutor} from '../../interfaces/IProposalGenericExecutor.sol';

/**
 * @dev This payload lists FRAX as collateral and borrowing asset on Aave V3 Polygon
 * - Parameter snapshot: https://snapshot.org/#/aave.eth/proposal/0xa464894c571fecf559fab1f1a8daf514250955d5ed2bc21eb3a153d03bbe67db
 * Opposed to the suggested parameters this proposal will
 * - Lowering the suggested 50M ceiling to a 2M ceiling
 * - Adding a 50M supply cap
 * - The eMode lq treshold will be 97.5, instead of the suggested 98% as the parameters are per emode not per asset
 * - The reserve factor will be 10% instead of 5% to be consistent with other stable coins
 */
contract WmaticPayload is IProposalGenericExecutor {
  // **************************
  // Protocol's contracts
  // **************************
  address public constant INCENTIVES_CONTROLLER =
    0x929EC64c34a17401F460460D4B9390518E5B473e;

  // **************************
  // Interest Rate Params
  // **************************
  // address public constant addressProvider = 0xa97684ead0e402dc232d5a977953df7ecbab3cdb;
  // uint256 public constant optimalUsageRatio = 750000000000000000000000000;
  // uint256 public constant baseVariableBorrowRate = 0;
  // uint256 public constant variableRateSlope1 = 61000000000000000000000000;
  // uint256 public constant variableRateSlope2 = 1000000000000000000000000000;
  // uint256 public constant stableRateSlope1 = 0;
  // uint256 public constant stableRateSlope2 = 0;
  // uint256 public constant baseStableRateOffset = 20000000000000000000000000;
  // uint256 public constant stableRateExcessOffset = 50000000000000000000000000;
  // uint256 public constant optimalStableToTotalDebtRatio = 200000000000000000000000000;

  address public constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

  address public constant INTEREST_RATE_STRATEGY =
    0xb9b42D95Be3350899706ca7C9EA3aAcb226C504F;

  function execute() external override {
    AaveV3Polygon.POOL_CONFIGURATOR.setReserveInterestRateStrategyAddress(WMATIC, INTEREST_RATE_STRATEGY);
  }
}
