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

contract DecentralisedStableCoin is ERC20Burnable, Ownable {
    //Errors
    error DecentralizedStableCoin__MustBeMoreThanZero();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();
    error DecentralizedStableCoin__NotZeroAddress();

    constructor()
        ERC20("DecentralizedStableCoin", "DSC")
        Ownable(msg.sender) //ownable now needs a deployer address
    {}

    function burn(uint256 _amount) public override onlyOwner {
        //burn function will help maintain the peg price
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

    function mint(
        //mint function basically mints some quantity(_amount) to a 'to' address
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            //revert with the below error if minting to a zero address
            revert DecentralizedStableCoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            //revert with below error if minting with amount less than or equal to zero
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
