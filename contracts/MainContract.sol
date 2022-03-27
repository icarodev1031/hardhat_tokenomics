//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
interface IERC20Token{
    function mint(address _to, uint256 _amount) external;
    function burn(uint256 _amount) external;
    function totalSupply() external returns(uint256);
}

contract MainContract{
    address public dollToken;
    address public wEth;
    uint256 public dollTokenMaxSupply = 50000 ether;
    address public uniRouter;

    constructor(address _dollToken, address _uniRouter, address _wEth){
        dollToken = _dollToken;
        wEth = _wEth;
        uniRouter = _uniRouter;
    }

    function doSomething() external payable{
        uint256 commision = msg.value;
        distributeRewards(commision);
        buyBackAndBurn(commision);
    }

    function distributeRewards(uint256 _commision) internal{
        uint256 dollTokenSupply = IERC20(dollToken).totalSupply();
        if(dollTokenSupply<dollTokenMaxSupply - 1 ether){
            uint256 remainingDollTokens = dollTokenMaxSupply - dollTokenSupply;
            uint diminishingSupplyFactor = remainingDollTokens * 100 / dollTokenMaxSupply;
            uint256 dollTokenDistro = _commision * diminishingSupplyFactor;
            require(dollTokenDistro >= 0, "dollTokenDistro bellow zero");
            IERC20Token(dollToken).mint(msg.sender, dollTokenDistro);

        }
    }

    function buyBackAndBurn(uint256 _amountIn) internal{
        uint24 poolFee = 3000;
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn:wEth,
            tokenOut: dollToken,
            fee: poolFee,
            recipient:address(this),
            deadline: block.timestamp,
            amountIn: _amountIn,
            amountOutMinimum:0,
            sqrtPriceLimitX96:0
        });
        uint amountOut = ISwapRouter(uniRouter).exactInputSingle{value:_amountIn}(params);
        IERC20Token(dollToken).burn(amountOut);
    }
}