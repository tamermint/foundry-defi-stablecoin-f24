// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";

contract DSCEngineTest is Test {
    DeployDSC public deployer;
    DecentralisedStableCoin public dsc;
    DSCEngine public dscEngine;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dscEngine) = deployer.run();
    }
}
