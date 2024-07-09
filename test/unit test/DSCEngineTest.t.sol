// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/Helperconfig.s.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockReentrantContract} from "./mockReentrantContract.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DSCEngineTest is Test {
    DeployDSC public deployer;
    DecentralisedStableCoin public dsc;
    DSCEngine public dscEngine;
    MockReentrantContract public attackerContract;
    HelperConfig public config;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;
    address wbtc;

    address public ATTACKER = makeAddr("attacker");
    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant ERC20_STARTING_BALANCE = 10 ether;
    uint256 public constant ATTACK_COLLATERAL = 1 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dscEngine, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = config.activeNetworkConfig();
        //need to mint tokens for the user so it's easy to manage
        ERC20Mock(weth).mint(USER, ERC20_STARTING_BALANCE);
        ERC20Mock(weth).mint(ATTACKER, ERC20_STARTING_BALANCE);

        vm.prank(USER);
        ERC20Mock(weth).approve(address(dscEngine), ERC20_STARTING_BALANCE);

        vm.prank(ATTACKER);
        ERC20Mock(weth).approve(address(dscEngine), ERC20_STARTING_BALANCE);

        attackerContract = new MockReentrantContract(address(dscEngine), weth);
    }

    /////////////////////////
    // Constructor tests ////
    /////////////////////////
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testIfTokenLengthDoesntMatchPriceFeed() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
    }

    ///////////////////
    // Price tests ////
    ///////////////////

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

    function testGetTokenAmountFromUsd() public view {
        uint256 usdAmount = 100 ether;
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = dscEngine.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
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

    function testRevertsWithUnapprovedCollateral() public {
        //to test whether the depositCollateral function reverts if the collateral is not approved
        ERC20Mock randToken = new ERC20Mock("RAN", "RAN", USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(DSCEngine.DSCEngine__TokenNotAllowed.selector);
        dscEngine.depositCollateral(address(randToken), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    /* function testRevertsDueToReentrantCall() public {
        vm.startPrank(ATTACKER);
        ERC20Mock(weth).transferInternal(ATTACKER, address(attackerContract), AMOUNT_COLLATERAL);
        ERC20Mock(weth).approveInternal(address(attackerContract), address(dscEngine), AMOUNT_COLLATERAL);

        vm.expectRevert(ReentrancyGuard.ReentrancyGuardReentrantCall.selector);
        attackerContract.attack();
        vm.stopPrank();
    } */
}
