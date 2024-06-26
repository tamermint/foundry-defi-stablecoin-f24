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

import {DecentralisedStableCoin} from "./DecentralisedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DSC Engine
 * @author Vivek Mitra
 *
 * System is designed to be minimal and maintain peg of 1 : 1 with USD i.e. 1 DSC == $1 USD
 * This stablecoin has the following properties:
 * - Exogenous Collateral (ETH, BTC)
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees and if it was only backed by wETH and wBTC.
 *
 * DSC System should always be "overcollateralized". At no point should the value of all collateral <= the $ backed value of all DSC
 *
 * @notice This contract is core of DSC System - it handles all the logic for mining and redeeming DSC - as well as depositing and withdrawing collateral
 * @notice This contract is loosely based on MakerDAO DSS (DAI)
 */
contract DSCEngine is ReentrancyGuard {
    /////////////////////
    ///// Errors ////////
    /////////////////////
    error DSCEngine__CanNotBeZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__TokenNotAllowed();
    error DSCEngine__TransferFailed();

    /////////////////////
    // State Variables //
    /////////////////////
    mapping(address token => address priceFeed) private s_PriceFeeds; //solidity pricefeed naming convention - new
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

    DecentralisedStableCoin private immutable i_dsc;

    /////////////////////
    ///// Events ////////
    /////////////////////
    event CollateralDeposited(address indexed user, address indexed tokens, uint256 indexed amount);

    /////////////////////
    //// Modifiers //////
    /////////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert DSCEngine__CanNotBeZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_PriceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed();
        }
        _;
    } //implementing a token allowlist - statemapping

    /////////////////////
    //// Functions //////
    /////////////////////
    constructor(
        address[] memory tokenAddresses, //intialize wBTC and wETH address - will be different based on diff chain
        address[] memory priceFeedAddresses, //initialize pricefeed address - - will be different based on diff chain
        address dscAddress //the address of our decentralised stable coin - so DSC engine can call the burn/mint function
    ) {
        //sanity check to ensure both the arrays have same length i.e. every token must have a corrsponding pricefeed address
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        //now map token address to respective pricefeed address
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_PriceFeeds[tokenAddresses[i]] = priceFeedAddresses[i]; //token at i = has pricefeed at i
        }
        i_dsc = DecentralisedStableCoin(dscAddress); //get instance of the stabelocing contract and set it to the i_dsc variable
    }

    ///////////////////////////
    // External Functions ////
    /////////////////////////

    function depositCollateralAndMintDsc() external {} //deposit wBTC/wETH and get DSC

    /**
     * @notice follows CEI pattern - checks, effects, interactions
     * @param tokenCollateralAddress The address of the token deposited as collateral - i.e. wBTC/wETH
     * @param amountCollateral The amount of collateral user deposits
     * @dev using OpenZeppelin's IERC20 interface's transferFrom function
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        //deposit collateral
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral); //emit event when state is updated
            //now transfer this amount to this contract using IERC20
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {} //redeem wBTC/wETH by depositing the DSC

    function redeemCollateral() external {} //redeem collateral

    function mintDsc() external {} //mint the DSC

    function burnDsc() external {} //burn DSC if people feel that they don't have enough collateral backing their DSC so they can burn DSC

    function liquidate() external {} //externals can call to save the protocol - by liquidating users positions - users can't hold same position if value of underlying collateral falls

    function getHealthFactor() external view {} //to see how healthy the positions are for specific addresses
}
