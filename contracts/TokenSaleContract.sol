
// import "tokens/eip20/EIP20.sol";
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
mapping(uint => uint256) priceToken;
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
    uint lockPeriod;
    uint vestingPeriod;
    uint releasePerDay;
    uint releasePerHour;
    uint price;
    uint256 issued;
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
    saleTokens[1] = block(1000000,0, 30,3.34,0.1391666667,0.15,0);
}

// end Sale
function endSale() onlyOwner external isSaleble {

 saleEnd = true;
 endTime = now;
}

// to buy tokens
function buyTokens(uint8 _block) isSaleble payable {
    require(balance[msg.sender].amount == 0,"buyer already exists");
    require(0 < _block &&_block < 5,"invalid block");
    
    uint256 amount = saleTokens[_block].price * msg.value;

    
    balance[msg.sender] = tokens(amount,_block);
    saleTokens[_block].issued.add(amount);
    require(saleTokens[_block].supply >= saleTokens[_block].issued,"issuence amount exceeds supply");
}

// to claim vested tokens
function tokenVesting(uint8 _block) external{

}
}
