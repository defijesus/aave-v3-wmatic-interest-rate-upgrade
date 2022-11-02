// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {AaveV3Polygon} from 'aave-address-book/AaveAddressBook.sol';
import {GovHelpers} from 'aave-helpers/GovHelpers.sol';
import {ProtocolV3TestBase, ReserveConfig, ReserveTokens, IERC20, InterestStrategyValues, IInterestRateStrategy} from 'aave-helpers/ProtocolV3TestBase.sol';
import {BridgeExecutorHelpers} from 'aave-helpers/BridgeExecutorHelpers.sol';
import {AaveGovernanceV2, IExecutorWithTimelock} from 'aave-address-book/AaveGovernanceV2.sol';
import {IStateReceiver} from 'governance-crosschain-bridges/contracts/dependencies/polygon/fxportal/FxChild.sol';
import {CrosschainForwarderPolygon} from '../../contracts/polygon/CrosschainForwarderPolygon.sol';
import {WmaticPayload} from '../../contracts/polygon/WmaticPayload.sol';
import {DeployL1PolygonProposal} from '../../../script/DeployL1PolygonProposal.s.sol';

contract PolygonWmaticE2ETest is ProtocolV3TestBase {
  // the identifiers of the forks
  uint256 mainnetFork;
  uint256 polygonFork;

  WmaticPayload public payload;

  address public constant CROSSCHAIN_FORWARDER_POLYGON =
    0x158a6bC04F0828318821baE797f50B0A1299d45b;
  address public constant BRIDGE_ADMIN =
    0x0000000000000000000000000000000000001001;
  address public constant FX_CHILD_ADDRESS =
    0x8397259c983751DAf40400790063935a11afa28a;
  address public constant POLYGON_BRIDGE_EXECUTOR =
    0xdc9A35B16DB4e126cFeDC41322b3a36454B1F772;

  address public constant INTEREST_RATE_STRATEGY = 0xb9b42D95Be3350899706ca7C9EA3aAcb226C504F;

  IInterestRateStrategy public constant OLD_INTEREST_RATE_STRATEGY = IInterestRateStrategy(0x03733F4E008d36f2e37F0080fF1c8DF756622E6F);

  // this ain't read from the old interest rate contract directly because it's a internal variable.
  uint256 public constant OLD_BASE_STABLE_RATE_OFFSET = 20000000000000000000000000;
  
  uint256 public constant NEW_VARIABLE_SLOPE_1 = 61000000000000000000000000;
  uint256 public constant NEW_VARIABLE_SLOPE_2 = 1000000000000000000000000000;
  uint256 public constant NEW_OPTIMAL_USAGE_RATIO = 750000000000000000000000000;
  uint256 public constant NEW_BASE_STABLE_BORROW_RATE = NEW_VARIABLE_SLOPE_1 + OLD_BASE_STABLE_RATE_OFFSET;

  function setUp() public {
    polygonFork = vm.createFork(vm.rpcUrl('polygon'), 34808266);
    mainnetFork = vm.createFork(vm.rpcUrl('ethereum'), 15829696);
  }

  function testProposalE2E() public {
    
    vm.selectFork(polygonFork);

    // we get all configs to later on check that payload only changes FRAX
    ReserveConfig[] memory allConfigsBefore = _getReservesConfigs(
      AaveV3Polygon.POOL
    );

    // 1. deploy l2 payload
    payload = new WmaticPayload();

    // 2. create l1 proposal
    vm.selectFork(mainnetFork);
    vm.startPrank(GovHelpers.AAVE_WHALE);
    uint256 proposalId = DeployL1PolygonProposal._deployL1Proposal(
      address(payload),
      0xec9d2289ab7db9bfbf2b0f2dd41ccdc0a4003e9e0d09e40dee09095145c63fb5 // TODO: replace with actual ipfs-hash
    );
    vm.stopPrank();

    // 3. execute proposal and record logs so we can extract the emitted StateSynced event
    vm.recordLogs();
    GovHelpers.passVoteAndExecute(vm, proposalId);

    Vm.Log[] memory entries = vm.getRecordedLogs();
    assertEq(
      keccak256('StateSynced(uint256,address,bytes)'),
      entries[2].topics[0]
    );
    assertEq(address(uint160(uint256(entries[2].topics[2]))), FX_CHILD_ADDRESS);

    // 4. mock the receive on l2 with the data emitted on StateSynced
    vm.selectFork(polygonFork);
    vm.startPrank(BRIDGE_ADMIN);
    IStateReceiver(FX_CHILD_ADDRESS).onStateReceive(
      uint256(entries[2].topics[1]),
      this._cutBytes(entries[2].data)
    );
    vm.stopPrank();

    // 5. Forward time & execute proposal
    BridgeExecutorHelpers.waitAndExecuteLatest(vm, POLYGON_BRIDGE_EXECUTOR);

    // 6. verify results

    InterestStrategyValues memory expectedIntRateStrat = InterestStrategyValues({
      addressesProvider: address(OLD_INTEREST_RATE_STRATEGY.ADDRESSES_PROVIDER()),
      optimalUsageRatio: NEW_OPTIMAL_USAGE_RATIO,
      optimalStableToTotalDebtRatio: OLD_INTEREST_RATE_STRATEGY.OPTIMAL_STABLE_TO_TOTAL_DEBT_RATIO(),
      baseStableBorrowRate: NEW_BASE_STABLE_BORROW_RATE,
      stableRateSlope1: OLD_INTEREST_RATE_STRATEGY.getStableRateSlope1(),
      stableRateSlope2: OLD_INTEREST_RATE_STRATEGY.getStableRateSlope2(),
      baseVariableBorrowRate: OLD_INTEREST_RATE_STRATEGY.getBaseVariableBorrowRate(),
      variableRateSlope1: NEW_VARIABLE_SLOPE_1,
      variableRateSlope2: NEW_VARIABLE_SLOPE_2
    });

    _validateInterestRateStrategy(
      payload.INTEREST_RATE_STRATEGY(),
      INTEREST_RATE_STRATEGY,
      expectedIntRateStrat
    );
  }

  // utility to transform memory to calldata so array range access is available
  function _cutBytes(bytes calldata input)
    public
    pure
    returns (bytes calldata)
  {
    return input[64:];
  }
}
