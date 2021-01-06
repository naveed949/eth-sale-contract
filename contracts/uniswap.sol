pragma solidity ^0.6.6;

import "contracts/uniswap/IUniswapV2Router02.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract UniswapExample {
  address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ; //kovan

  IUniswapV2Router02 public uniswapRouter;

  constructor() public {
    uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
  }

  function convertEthToToken(uint tokenAmount,address tokenAdd,uint ethAmount) public {

     uint deadline1 = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
     uniswapRouter.swapETHForExactTokens{ value: ethAmount }(tokenAmount, getPathForETHtoToken(tokenAdd), address(this), deadline1);

 }

  function convertTokenToEth(uint ethAmount,uint tokAmount,   address tokenAdd ) public {

        uint deadline2 = block.timestamp + 30;
       
        IERC20 tok = IERC20(tokenAdd);
       
        require(tok.approve(address(uniswapRouter),tokAmount),"Approve failed");
   
        uniswapRouter.swapExactTokensForETH(tokAmount,ethAmount, getPathForTokentoETH(tokenAdd), address(this), deadline2);

      }


  function getEstimatedETHforToken(uint tokAmount , address tokenAdd) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsOut(tokAmount, getPathForETHtoToken(tokenAdd));
  }
 
  function getEstimatedTokenforEth(uint tokAmount , address tokenAdd) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsOut(tokAmount, getPathForTokentoETH(tokenAdd));
  }


  function getPathForETHtoToken(address tokenAdd) private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = tokenAdd;

    return path;
  }

  function getPathForTokentoETH(address tokenAdd) private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = tokenAdd;
    path[1] = uniswapRouter.WETH();

    return path;
  }
 
 
  function getBalance(address token ) public view returns (uint ) {
    IERC20 tok = IERC20(token);
    return tok.balanceOf(address(this));
  }
 
 function getEthBalance() public view returns (uint ) {
        return address(this).balance;

  }
 

}
