// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/Helperconfig.s.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DeployDSC public deployer;
    DecentralisedStableCoin public dsc;
    DSCEngine public dscEngine;
    HelperConfig public config;
    address ethUsdPriceFeed;
    address weth;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant ERC20_STARTING_BALANCE = 10 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dscEngine, config) = deployer.run();
        (ethUsdPriceFeed,, weth,,) = config.activeNetworkConfig();
        //need to mint tokens for the user so it's easy to manage
        ERC20Mock(weth).mint(USER, ERC20_STARTING_BALANCE);
    }

    //////////////////
    // Price tests //
    /////////////////

    function testGetUsdValue() public view {
        //to test whether the getUsd value returns the correct value from the price feed
        //function getUsdValue(address token, uint256 amount) public view returns (uint256) - testing this
        uint256 ethAmount = 15e18; //testing for this amnount of eth
        uint256 expectedUsdValue = 30000e18;
        uint256 actualUsdValue = dscEngine.getUsdValue(weth, ethAmount);
        console.log("Expected USD value:", expectedUsdValue);
        console.log("Actual USD value:", actualUsdValue);
        assertEq(actualUsdValue, expectedUsdValue);
    }

    //////////////////////////////
    // depositCollateral tests ///
    //////////////////////////////

    function testRevertsIfCollateralIsZero() public {
        //to test whether the depositCollateral function reverts if the collateral is zero
        vm.startPrank(USER); //set context of a user so that dsc engine test is not the user
        ERC20Mock(weth).approve(address(dscEngine), AMOUNT_COLLATERAL); //approve an amount
        vm.expectRevert(DSCEngine.DSCEngine__CanNotBeZero.selector);
        dscEngine.depositCollateral(weth, 0); //deposit zero
        vm.stopPrank();
    }
}
