// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {WmaticPayload} from '../src/contracts/polygon/WmaticPayload.sol';

contract DeployPolygonWmatic is Script {
  function run() external {
    vm.startBroadcast();
    new WmaticPayload();
    vm.stopBroadcast();
  }
}
