// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";
/**
 * @title OracleLib
 * @author Vivek Mitra
 * @notice This library is used to check Chainlink Oracle for stale data
 * If a price is stale, function will revert and render DSC engine unusable
 * We want the dsc engine to freeze if prices become stale
 *
 * if chainlink protocol blows up and you have lot of money locked up in the protocol, you are screwed
 */

library OracleLib {
    error OracleLib__StalePrice();

    uint256 public constant TIMEOUT = 3 hours;

    function staleCheckLatestRoundData(AggregatorV3Interface priceFeed)
        public
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            priceFeed.latestRoundData();

        if (updatedAt == 0 || answeredInRound < roundId) {
            revert OracleLib__StalePrice();
        }

        uint256 secondsSinceLastUpdate = block.timestamp - updatedAt;
        if (secondsSinceLastUpdate > TIMEOUT) revert OracleLib__StalePrice();

        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
