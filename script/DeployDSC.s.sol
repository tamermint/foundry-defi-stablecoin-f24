// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {DecentralisedStableCoin} from "../src/DecentralisedStableCoin.sol";
import {HelperConfig} from "../script/Helperconfig.s.sol";

contract DeployDSC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (DecentralisedStableCoin, DSCEngine) {
        HelperConfig helperConfig = new HelperConfig();
        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            helperConfig.activeNetworkConfig();
        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed]
        vm.startBroadcast(deployerKey);
        DecentralisedStableCoin dsc = new DecentralisedStableCoin();
        DSCEngine dscEngine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc)); //-> DSC engine needs 3 params - the dsc address, the array of token addresses and the array of pricefeed addresses
        dsc.transferOwnership(address(dscEngine));  //it's a way of transferring ownership of the stablecoin to the dsc engine contract
        vm.stopBroadcast(deployerKey);
        return (dsc, dscEngine);
    }
}
