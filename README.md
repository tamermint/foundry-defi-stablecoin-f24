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
  old :

```solidity
contract ERC20Mock is ERC20 {
    constructor(string memory name, string memory symbol, address initialAccount, uint256 initialBalance)
        payable
        ERC20(name, symbol)
    {
        _mint(initialAccount, initialBalance);
    }
    ...}
```

new :

```solidity
    contract ERC20Mock is ERC20 {
    constructor() ERC20("ERC20Mock", "E20M") {}
    ...}
```

- In the initial invariant tests, we need to approve the handler contract and mint money as well :

```solidity
     constructor(DSCEngine _dsce, DecentralisedStableCoin _dsc) {
        dsce = _dsce;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        >weth.mint(address(this), 1000 * 10e18);
        >wbtc.mint(address(this), 1000 * 10e18);
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

        >collateral.approve(address(dsce), amountCollateral);
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


```
