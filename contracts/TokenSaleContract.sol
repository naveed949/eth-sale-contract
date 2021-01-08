pragma solidity ^0.6.6;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "contracts/uniswap.sol";

/// @title  TokenSaleContract - A sale contract of token plus uniswap
///         implementation that is backed by ether.
contract TokenSale is Ownable, ERC20 {

using SafeMath for uint256;

uint startTime;
uint endTime;
uint256 softCap;
uint256 hardCap;
uint256 ethPrice;
uint256 minBuy;
uint256 maxBuy;
uint256 uniswapEth;
uint256 referalEthReward;
bool saleEnd;
address payable companyWallet;

constructor(uint _startTime, uint256 _softCap, uint256 _hardCap, uint256 _minBuy, uint256 _maxBuy, address payable _wallet, string memory _tokenName, string memory _symbol) ERC20(_tokenName,_symbol) public {
    startTime = _startTime;
    softCap = _softCap;
    hardCap = _hardCap;
    minBuy = _minBuy;
    maxBuy = _maxBuy;
    companyWallet = _wallet;
    initBlocks();
}

// Allow other ERC20 tokens to be withdrawn from contract in case of accidental deposit, except
// for the token being sold.
function withdrawERC20(uint256 _amount, address _token, address _to) onlyOwner external {
    ERC20 erc20 =  ERC20(_token);
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
struct TokenBlock {
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
mapping(uint8 => TokenBlock) public saleTokens;
mapping(uint8 => TokenBlock) nonsaleTokens;

struct tokens {
    uint256 amount;
    uint256 lastVestingTime;
    uint8 blockId;
}
mapping(address => tokens) balance;
// init blocks 1-4 saleable & 5 nonsaleable blocks
function initBlocks() internal {
    saleTokens[1] = TokenBlock(1000000,0 days, 30 days,334,10000,1391666667,1000000000000,0.15 ether,0);
    saleTokens[2] = TokenBlock(2000000,0 days, 14 days,715,10000,2979166667,1000000000000,0.20 ether,0);
    saleTokens[3] = TokenBlock(3000000,0 days, 7 days,143,1000,5958333333,1000000000000,0.25 ether,0);
    saleTokens[4] = TokenBlock(4000000,0 days, 0 days,1,100,41666666667,1000000000000,0.30 ether,0);
    saleTokens[5] = TokenBlock(1000000,30 days, 180 days,5479452055,1000000000000,228310502,1000000000000,0 ether,0); // advisors block
    saleTokens[6] = TokenBlock(2000000,0 days, 365 days,2739726027,1000000000000,114155251,1000000000000,0 ether,0); // marketing/staking block
    saleTokens[7] = TokenBlock(2000000,180 days, 3*365 days,1,1000,41666667,1000000000000,0 ether,0); // team block
    saleTokens[8] = TokenBlock(500000,0 days, 365 days,2739726027,1000000000000,114155251,1000000000000,0 ether,0); // bounty block
    saleTokens[9] = TokenBlock(500000,180 days, 180 days,108,10000,45,100000,0 ether,0); // airdrops block
}

// end Sale
function endSale() onlyOwner external isSaleble returns (bool) {

 saleEnd = true;
 endTime = now;
 // burn tokens which are not issued yet saleable tokens only e.g burnable = supply - issued
 for(uint8 i = 1; i <= 4; i++){
     if(saleTokens[i].supply > saleTokens[i].issued){
         // burning extra tokens
         saleTokens[i].supply = saleTokens[i].issued;
     }
 }
 // transfer raised eth to respective addresses as per quota
    // 67.5% to company wallet, 30% for uniswap, 2.5% for referals
    uint256 eths;
        eths = perCalc(address(this).balance,675,1000);
        companyWallet.transfer(eths);
        uniswapEth = perCalc(address(this).balance,30,100);
        referalEthReward = perCalc(address(this).balance,25,1000);
    return true;
}
/// Ability to add users after sale ended in nonsaleable blocks
function issueNonSaleTokens(address account,uint256 amount, uint8 _block) onlyOwner external {
    require(balance[account].amount == 0,"buyer already exists");
    require(4 < _block &&_block < 10,"invalid block"); 

    balance[account] = tokens(amount,0,_block);
    saleTokens[_block].issued.add(amount);
    require(saleTokens[_block].supply >= saleTokens[_block].issued,"amount exceeds block supply");
}
// to buy tokens
function buyTokens(uint8 _block) isSaleble payable external {
    
    require(balance[msg.sender].amount == 0,"buyer already exists");
    require(0 < _block &&_block < 5,"invalid block");
    
    uint256 amount = msg.value / (saleTokens[_block].price );  // price in eth but value in wei :/ (auto conversion)
    require(minBuy <= amount,"amount too low");
    require(amount <= maxBuy,"amount too high");
    
    balance[msg.sender] = tokens(amount,0,_block);
    saleTokens[_block].issued.add(amount);
    require(saleTokens[_block].supply >= saleTokens[_block].issued,"amount exceeds supply");

    emit BuyTokens(msg.sender,_block,amount);
}

// to claim vested tokens
function claim(uint8 _block) external {
// sale & lock period ended, vesting calculation
require(saleEnd && ( saleTokens[_block].lockPeriod + endTime ) < now, "vesting isn't started yet");
require(balance[msg.sender].blockId == _block && balance[msg.sender].amount > 0, "no tokens to vest");

// save last vested time and then caclulate current with it to find how much to be vested now and then update last vvested time
// calculate no. hours. obtain 1 hour amount and multiply with total hours
uint value = perCalc(balance[msg.sender].amount, saleTokens[_block].releasePerHourPerc, saleTokens[_block].releasePerHourDiv);
uint hour;
if(balance[msg.sender].lastVestingTime == 0){
     hour = (now - saleTokens[_block].lockPeriod + endTime).div(1 hours);
}else
 hour = (now - balance[msg.sender].lastVestingTime).div(1 hours);

 value = value.mul(hour);
 // last vesting time update
 balance[msg.sender].lastVestingTime = now;
// vested tokens deduct from block's tokens
if(balance[msg.sender].amount >= value){
    balance[msg.sender].amount.sub(value);
}else{
    value = balance[msg.sender].amount;
    balance[msg.sender].amount = 0;
}

// add tokens to erc20 supply as vested tokens to be consumed and used as user wants.
_mint(msg.sender, value);
// emit token vested
emit Vesting(msg.sender,value,_block);
}


function perCalc(uint amount, uint percentage, uint div) pure internal returns(uint ){
    return ( amount * percentage ) / div;
}
function balanceOfBlock(address account) view external returns(uint _amount,uint _block){
    return (balance[account].amount,balance[account].blockId);
}
function referalReward(address payable account, uint256 amount) onlyOwner external {
    require(referalEthReward > 0,"no funds left to send");
    account.transfer(amount);
    referalEthReward.sub(amount);
}
function uniswapEthWithdraw(address payable account) onlyOwner external {
    require(uniswapEth > 0,"no funds to send");
    account.transfer(uniswapEth);
    uniswapEth = 0;
}
event Vesting(address indexed account, uint256 amount, uint8 blockId);
event BuyTokens(address indexed account, uint8 indexed block, uint256 amount);
}
