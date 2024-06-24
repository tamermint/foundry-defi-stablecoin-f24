// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;

/**
 * @title Decentralized stable coin
 * @author Vivek Mitra
 * @notice This contract is implementation of the stablecoin system
 * The main contract for the logic will be DSCEngine.sol, the governing engine
 * Collateral: Exogenous (ETH and BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged
 */

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    //Errors
    error DecentralizedStableCoin__MustBeMoreThanZero();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();

    constructor()
        ERC20("DecentralizedStableCoin", "DSC")
        Ownable(0x4aB7C05Ca6281deA5A95C40CD5B11ad0CFA5836E)
    {}

    function burn(uint256 _amount) public override onlyOwner {
        //implementing a burn function
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            //we don't want to burn 0
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }
        if (balance < _amount) {
            //if user has less balance than burn amount, revert
            revert DecentralizedStableCoin__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }
}
