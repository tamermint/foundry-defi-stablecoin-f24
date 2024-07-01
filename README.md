# Defi Stablecoin Project - Advanced Foundry/Cyfrin

## Design consideration

- Relative Stability - Anchored/Pegged -> to USD
  - This can be acheived by the chainlink price feed
  - Set a function to exchange ETH/BTC for $$ equivalent
- Stability mechanism (minting) : Algorithmic (Decentralised)
  - People can only mint stablecoin with enough collateral only (coded)
- Collateral type - Exogenous (Crypto Collateral)
  - wETH
  - wBTC

## Project Changes

- ERC20 mock contract needed to be installed - OpenZeppelin has had changes and no longer accepts 4 constructors
