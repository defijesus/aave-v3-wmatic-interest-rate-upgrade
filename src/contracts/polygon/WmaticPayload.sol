// SPDX-License-Identifier: MIT

/*
   _      ΞΞΞΞ      _
  /_;-.__ / _\  _.-;_\
     `-._`'`_/'`.-'
         `\   /`
          |  /
         /-.(
         \_._\
          \ \`;
           > |/
          / //
          |//
          \(\
           ``
     defijesus.eth
*/

pragma solidity ^0.8.0;

import {AaveV3Polygon} from 'aave-address-book/AaveV3Polygon.sol';
import {IProposalGenericExecutor} from '../../interfaces/IProposalGenericExecutor.sol';

/**
 * @title WmaticPayload
 * @author Llama
 * @dev This payload changes the interest rate strategy of WMATIC to a new one
 * Governance Post: https://governance.aave.com/t/arc-aave-v3-polygon-wmatic-interest-rate-update/10290
 * Snapshot: https://snapshot.org/#/aave.eth/proposal/0xf9c8b9761462856a18eca20a67a369710593bc5a8599ed5375a46c3ab74158ea
 */
contract WmaticPayload is IProposalGenericExecutor {
  // **************************
  // INTEREST_RATE_STRATEGY Params Updates
  // **************************
  // optimalUsageRatio updated to 750000000000000000000000000;
  // variableRateSlope1 updated to 61000000000000000000000000;
  // variableRateSlope2 updated to 1000000000000000000000000000;

  address public constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

  address public constant INTEREST_RATE_STRATEGY =
    0xb9b42D95Be3350899706ca7C9EA3aAcb226C504F;

  function execute() external override {
    AaveV3Polygon.POOL_CONFIGURATOR.setReserveInterestRateStrategyAddress(WMATIC, INTEREST_RATE_STRATEGY);
  }
}
