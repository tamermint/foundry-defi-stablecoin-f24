// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {DecentralisedStableCoin} from "../src/DecentralisedStableCoin.sol";

contract DeployDSC is Script {
    function run() external returns (DecentralisedStableCoin, DSCEngine) {
        vm.startBroadcast();
        DecentralisedStableCoin dsc = new DecentralisedStableCoin();
        //DSCEngine dscEngine = new DSCEngine(address(dsc)); -> DSC engine needs 3 params - the dsc address, the array of token addresses and the array of pricefeed addresses
        vm.stopBroadcast();
    }
}
