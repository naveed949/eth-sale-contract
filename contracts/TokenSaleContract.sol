import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";

/// @title  TokenSaleContract - A sale contract of token plus uniswap
///         implementation that is backed by ether.
contract TokenSale is Crowdsale, Ownable {

using SafeMath for uint256;

uint startTime;
uint endTime;
uint256 softCap;
uint256 hardCap;
uint256 ethPrice;
uint256 minBuy;
uint256 maxBuy;

bool saleEnd;
// Allow other ERC20 tokens to be withdrawn from contract in case of accidental deposit, except
// for the token being sold.
function withdrawERC20(uint256 _amount, address _token, address _to) onlyOwner external {
ERC20Basic erc20 =  ERC20Basic(_token);
erc20.transfer(_to, _amount);
}

// start sale
modifier isSaleStarted {
require(now >= startTime);
_;
}
// check if sale ended or not
modifier isSaleble {
require(now >= startTime,"sale not yet started");
require(!saleEnd,"Sale ended");
_;
}
struct block {
    uint supply;
    uint lockPeriod; // days
    uint vestingPeriod;  // days
    uint releasePerDayPerc;
    uint releasePerDayDiv;
    uint releasePerHourPerc;
    uint releasePerHourDiv;
    uint price;
    uint256 issued;
  //   mapping(address => uint) holders;
}
mapping(uint8 => block) saleTokens;
mapping(uint8 => block) nonsaleTokens;

struct tokens {
    uint256 amount;
    uint8 blockId;
}
mapping(address => tokens) balance;
// init blocks 1-4 saleable & 5 nonsaleable blocks
function initBlocks() internal {
    saleTokens[1] = block(1000000,0 days, 30 days,334,10000,1391666667,1000000000000,0.15 ether,0);
    saleTokens[2] = block(2000000,0 days, 14 days,715,10000,2979166667,1000000000000,0.20 ether,0);
    saleTokens[3] = block(3000000,0 days, 7 days,143,1000,5958333333,1000000000000,0.25 ether,0);
    saleTokens[4] = block(4000000,0 days, 0 days,1,100,41666666667,1000000000000,0.30 ether,0);
    saleTokens[5] = block(1000000,30 days, 180 days,5479452055,1000000000000,228310502,1000000000000,0.30 ether,0); // advisors block
}

// end Sale
function endSale() onlyOwner external isSaleble {

 saleEnd = true;
 endTime = now;
}

// to buy tokens
function buyTokens(uint8 _block) isSaleble payable {
    require(minBuy < msg.value && msg.value < maxBuy,"buyer limit mismatched");
    require(balance[msg.sender].amount == 0,"buyer already exists");
    require(0 < _block &&_block < 5,"invalid block");
    
    uint256 amount = (saleTokens[_block].price ) * msg.value;  // price in eth but value in wei :/

    
    balance[msg.sender] = tokens(amount,_block);
    saleTokens[_block].issued.add(amount);
    require(saleTokens[_block].supply >= saleTokens[_block].issued,"amount exceeds supply");
}

// to claim vested tokens
function tokenVesting(uint8 _block) internal{
// sale & lock period ended, vesting calculation
require(saleEnd && ( saleTokens[_block].lockPeriod + endTime ) > now, "Vesting isn't enabled yet");
require(balance[msg.sender].amount > 0, "no tokens to vest");

uint value = perCalc(balance[msg.sender].amount, saleTokens[_block].)
}

function perCalc(uint amount, uint percentage, uint div) internal returns(uint ){
    return ( amount * percentage ) / div;
}
}
