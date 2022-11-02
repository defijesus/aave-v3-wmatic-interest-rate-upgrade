// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon} from 'aave-address-book/AaveV3Polygon.sol';
import {IProposalGenericExecutor} from '../../interfaces/IProposalGenericExecutor.sol';

/**
 * @dev This payload changes the interest rate strategy of WMATIC to a new one
 */
contract WmaticPayload is IProposalGenericExecutor {
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
