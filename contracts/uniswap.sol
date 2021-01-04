pragma solidity 0.6.6;

import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IERC20.sol";
//import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';

contract UniswapExample {
  address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ;

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

  function convertTokenToToken(uint tokenInAmount,uint tokenOutAmount , address tokenIn, address tokenOut) public {

        uint deadline2 = block.timestamp + 30;
   
        IERC20 tok = IERC20(tokenIn);
   
        require(tok.approve(address(uniswapRouter),tokenInAmount),"Approve failed");

        uniswapRouter.swapExactTokensForTokens(tokenInAmount,tokenOutAmount, getPathForTokentoToken(tokenIn,tokenOut), address(this), deadline2);
   
    }

  function getEstimatedETHforToken(uint tokAmount , address tokenAdd) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsOut(tokAmount, getPathForETHtoToken(tokenAdd));
  }
 
  function getEstimatedTokenforEth(uint tokAmount , address tokenAdd) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsOut(tokAmount, getPathForTokentoETH(tokenAdd));
  }

  function getEstimatedTokenforToken(uint tokAmount, address tokenIn, address tokenOut ) public view returns (uint[] memory) {
    return uniswapRouter.getAmountsOut(tokAmount, getPathForTokentoToken(tokenIn,tokenOut));
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

   function getPathForTokentoToken(address tokenIn,address tokenOut) private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = tokenIn;
    path[1] = tokenOut;

    return path;
  }
 
  function swapEth(address[] memory tokens,uint tokAmount) public {
     

    for( uint i=0 ; i <= tokens.length ; i++ ){
       
       if(i==0){
           
           convertEthToToken(tokAmount,tokens[0],address(this).balance);
       }
       else if(i == tokens.length){
           IERC20 tok = IERC20(tokens[i-1]);
           convertTokenToEth(0,tok.balanceOf(address(this)),tokens[i-1]);
       }
       else{
           
           IERC20 tok = IERC20(tokens[i-1]);
           convertTokenToToken(tok.balanceOf(address(this)),0,tokens[i-1],tokens[i]);
       }
    }
  }
 
  function getBalance(address token ) public view returns (uint ) {
    IERC20 tok = IERC20(token);
    return tok.balanceOf(address(this));
  }
 
 function getEthBalance() public view returns (uint ) {
        return address(this).balance;

  }
 
  function withdraw(address payable to) public {

    to.transfer(address(this).balance);
   
  }
 
 
  function withdrawToken(address to,address tok) public {
       
        IERC20 tokk = IERC20(tok);
        tokk.transfer(to,tokk.balanceOf(address(this)));
   
  }
 
  function deposit() public payable returns (uint ){

     return address(this).balance;
  }


  // important to receive ETH
  receive() payable external {}
}
