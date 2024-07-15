// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract Handler is Test {
    DSCEngine public dsce;
    DecentralisedStableCoin public dsc;
    ERC20Mock weth;
    ERC20Mock wbtc;

    constructor(DSCEngine _dsce, DecentralisedStableCoin _dsc) {
        dsce = _dsce;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        weth.mint(address(this), 1000 * 10e18);
        wbtc.mint(address(this), 1000 * 10e18);
    }

    //redeem collateral
    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) external {
        //this would have broken as we would allow any collateral token, but now we are restricting to wbtc and weth
        /*  ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        collateral.approve(address(dsce), amountCollateral);
        dsce.depositCollateral(address(collateral), amountCollateral); */
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

        console.log("Balance before deposit: ", collateral.balanceOf(msg.sender));
        console.log("Allowance before deposit: ", collateral.allowance(msg.sender, address(dsce)));

        collateral.approve(address(dsce), amountCollateral);
        dsce.depositCollateral(address(collateral), amountCollateral);

        console.log("Balance after deposit: ", collateral.balanceOf(msg.sender));
        console.log("Allowance after deposit: ", collateral.allowance(msg.sender, address(dsce)));
    }

    //Helper functions

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
