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
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

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
    error DSCEngine__BreaksHealthFactor(uint256 healthFactor);
    error DSCEngine__MintFailed();

    /////////////////////
    // State Variables //
    /////////////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; //to ensure the protocol is always overcollateralized
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeed) private s_priceFeeds; //solidity pricefeed naming convention - new
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited; //mapping to store the collateral deposited
    mapping(address user => uint256 dscMinted) private s_DSCMinted;
    address[] private s_collateralTokens; //address array to store the addresses of the tokens deposited

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
        if (s_priceFeeds[token] == address(0)) {
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
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i]; //token at i = has pricefeed at i
            s_collateralTokens.push(tokenAddresses[i]); //push the address of the token into this array
        }
        i_dsc = DecentralisedStableCoin(dscAddress); //get instance of the stablecoin contract and set it to the i_dsc variable
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

    /**
     * @notice Follows the CEI pattern
     * @param amountDscToMint The amount of decentralis0ed stablecoin to mint
     * @notice They must have more collateral than dsc
     */
    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
        //1. check if colllatera value > dsc amount
        s_DSCMinted[msg.sender] += amountDscToMint;
        _revertIfHealthFactorIsBroken(msg.sender); //this will be an internal function to check if they can borrow dsc otherwise revert
        //mint the DSC
        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if (!minted) {
            revert DSCEngine__MintFailed();
        }
    }

    function burnDsc() external {} //burn DSC if people feel that they don't have enough collateral backing their DSC so they can burn DSC

    function liquidate() external {} //externals can call to save the protocol - by liquidating users positions - users can't hold same position if value of underlying collateral falls

    function getHealthFactor() external view {} //to see how healthy the positions are for specific addresses

    ///////////////////////////
    // Internal Functions ////
    /////////////////////////

    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        //get the total DSC minted for this user
        totalDscMinted = s_DSCMinted[user];
        //get the total collateral value, not just the amount of collateral, for this user
        collateralValueInUsd = getAccountCollateralValueInUsd(user);
        //in order to get the collateral value in usd, need to loop through the tokens deposited as collateral
    }

    /**
     * @notice return how close to liquidation a user is, if they go below 1, they can get liquidated
     * @dev the calculation depends on collateral in eth, liquidation threshold and total borrowed
     */
    function _healthFactor(address user) private view returns (uint256) {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
        // return (collateralValueInUsd / totalDscMinted);
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine__BreaksHealthFactor(userHealthFactor);
        }
    }

    ///////////////////////////
    // Public view Functions /
    /////////////////////////
    function getAccountCollateralValueInUsd(address user) public view returns (uint256 totalCollateralValueInUsd) {
        //first go through the tokens deposited, then get the amount deposited and then map it to the
        //price to get value in usd
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        //using the aggregator pricefeed
        //get the price of the token in usd
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.latestRoundData();
        //the returned value is 8 decimal places
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }
}
