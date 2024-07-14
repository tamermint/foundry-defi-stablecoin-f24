// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
//need to ask the question - > which properties will always be true
// What are our invariants?
// 1. Total supply of DSC should be less than total value of collateral
// 2. Getter view functions should never revert -> evergreen invariant

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {HelperConfig} from "../../script/Helperconfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralisedStableCoin dsc;
    HelperConfig helper;
    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, helper) = deployer.run();
        targetContract(address(dsce));
        (,, weth, wbtc,) = helper.activeNetworkConfig();
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        //first get the total collateral value in the protocol
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

        uint256 wethUsdValue = dsce.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcUsdValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);

        console.log("weth value: ", wethUsdValue);
        console.log("wbtc value: ", wbtcUsdValue);
        console.log("total supply: ", totalSupply);

        assert(wethUsdValue + wbtcUsdValue >= totalSupply);
    }
}
