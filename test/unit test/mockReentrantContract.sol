// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DSCEngine} from "../../src/DSCEngine.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockReentrantContract {
    DSCEngine public dscEngine;
    IERC20 public token;
    uint256 public constant ATTACK_COLLATERAL = 1 ether;

    constructor(address _dscEngine, address _token) {
        dscEngine = DSCEngine(_dscEngine);
        token = IERC20(_token);
    }

    function attack() external {
        dscEngine.depositCollateral(address(token), ATTACK_COLLATERAL);
        dscEngine.depositCollateral(address(token), ATTACK_COLLATERAL);
        dscEngine.depositCollateral(address(token), ATTACK_COLLATERAL);
    }

    fallback() external payable {
        dscEngine.depositCollateral(address(token), ATTACK_COLLATERAL);
    }

    receive() external payable {
        dscEngine.depositCollateral(address(token), ATTACK_COLLATERAL);
    }
}
