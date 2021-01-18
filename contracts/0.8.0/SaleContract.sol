// File: openzeppelin-solidity/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/GSN/Context.sol



pragma solidity 0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: openzeppelin-solidity/contracts/access/Ownable.sol



pragma solidity 0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



pragma solidity 0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/IToken.sol



pragma solidity 0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IToken {

    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(uint256 _amount) external returns(bool);

}

// File: contracts/SaleContract.sol



pragma solidity 0.8.0;

/// @title  TokenSaleContract - A sale contract of token plus uniswap
///         implementation that is backed by ether.
contract TokenSale is Ownable {

using SafeMath for uint256;


uint256 public startTime;
uint256 public endTime;
uint256 public softCap;
uint256 public hardCap;
uint256 public ethPrice;
uint256 public minBuy;
uint256 public maxBuy;
uint256 uniswapEth;
uint256 public totalEthRaised;
bool saleEnd;

address payable companyWallet;
IToken  erc20Token;

constructor(uint _startTime, uint256 _softCap, uint256 _hardCap, uint256 _minBuy, uint256 _maxBuy, address payable _companyWallet, uint256 _ethPrice) {
    startTime = _startTime;
    softCap = _softCap;
    hardCap = _hardCap;
    minBuy = _minBuy;
    maxBuy = _maxBuy;
    companyWallet = _companyWallet;
    ethPrice = _ethPrice;
    initBlocks();
}

// Allow other ERC20 tokens to be withdrawn from contract in case of accidental deposit, except
// for the token being sold.
function withdrawERC20(uint256 _amount, address _token, address _to) onlyOwner external {
    IERC20 erc20 =  IERC20(_token);
    erc20.transfer(_to, _amount);
}

// start sale
modifier isSaleStarted {
    require(block.timestamp>= startTime);
    _;
}
// check if sale ended or not
modifier isSaleble {
    require(block.timestamp>= startTime,"sale not yet started");
    require(!saleEnd,"sale ended");
    _;
}
struct TokenBlock {
    uint supply;
    uint256 lockPeriod; // days
    uint256 vestingPeriod;  // days
    uint releasePerDayPerc;
    uint releasePerDayDiv;
    uint releasePerHourPerc;
    uint releasePerHourDiv;
    uint price;
    uint256 issued;
}
mapping(uint8 => TokenBlock) public saleTokens;
mapping(uint8 => TokenBlock) nonsaleTokens;
mapping(address => address payable) referals;
struct tokens {
    uint256 amount;
    uint256 lastVestingTime;
    uint256 amountVested;
    uint8 blockId;
}
mapping(address => tokens) balance;
// init blocks 1-4 saleable & 5 nonsaleable blocks
function initBlocks() internal {
    // setting supply in ehters just to ensure 18 decimals, price in pennies 
    saleTokens[1] = TokenBlock(1000000 ether,0 days, 30 days,334,10000,1391666667,1000000000000,15 ,0); // private block
    saleTokens[2] = TokenBlock(2000000 ether,0 days, 14 days,715,10000,2979166667,1000000000000,20 ,0);
    saleTokens[3] = TokenBlock(3000000 ether,0 days, 7 days,143,1000,5958333333,1000000000000,25 ,0);
    saleTokens[4] = TokenBlock(4000000 ether,0 days, 0 days,100,100,100,100,30 ,0);
    saleTokens[5] = TokenBlock(1000000 ether,30 days, 180 days,5479452055,1000000000000,228310502,1000000000000,0 ,0); // advisors block
    saleTokens[6] = TokenBlock(1000000 ether,0 days, 365 days,2739726027,1000000000000,114155251,1000000000000,0 ,0); // marketing/staking block
    saleTokens[7] = TokenBlock(1500000 ether,180 days, 3*365 days,1,1000,41666667,1000000000000,0 ,0); // team block
    saleTokens[8] = TokenBlock(1500000 ether,30 days, 3*365 days,1,1000,41666667,1000000000000,0 ,0); // foundation block
    saleTokens[9] = TokenBlock(1500000 ether,90 days, 180 days,5479452055,1000000000000,228310502,1000000000000,0 ,0); // seed block
}
function _endSale() internal {
  saleEnd = true;
 endTime = block.timestamp;
 uint256 _toBeBurned;
 // burn tokens which are not issued yet saleable tokens only e.g burnable = supply - issued
 for(uint8 i = 1; i <= 4; i++){
     if(saleTokens[i].supply > saleTokens[i].issued){
         _toBeBurned = _toBeBurned.add(saleTokens[i].supply - saleTokens[i].issued );
         // burning extra tokens
         saleTokens[i].supply = saleTokens[i].issued;
         
     }
 }
 erc20Token.burn(_toBeBurned);
 
        
    emit EndSale(endTime);  
}
// end Sale
function endSale() onlyOwner public isSaleble  {

 _endSale();
    
}
/// Ability to add users after sale ended in nonsaleable blocks, also multiple addresses with amounts can be added
function issueNonSaleTokens(address[] memory account,uint256[] memory amount, uint8 _block) onlyOwner external {
    
    require(_block == 1 || (4 < _block &&_block < 10),"invalid block");
    // only block#5 adviser allowed to be added new accounts after sale ended.
    if(_block != 5){
        require(!saleEnd,"sale ended");
    }
    require(account.length == amount.length,"lists mismatched");
    for(uint8 i=0; i < account.length; i++){

    require(balance[account[i]].amount == 0,"account already exists");
    balance[account[i]] = tokens(amount[i],0,0,_block);
    saleTokens[_block].issued.add(amount[i]);
    require(saleTokens[_block].supply >= saleTokens[_block].issued,"amount exceeds block supply");
    emit Issue(account[i],amount[i],_block);
     }
}
// to buy tokens
function buyTokens(uint8 _block) isSaleble payable external {
    
    require(1 < _block &&_block < 5,"invalid block"); //excluding block#1 which private now
    require(minBuy <= msg.value,"eth sent too low");
    require(msg.value <= maxBuy,"eth sent too high");

    require(balance[msg.sender].amount == 0,"buyer already exists");

    uint256 tokensPerEth = ethPrice.div(saleTokens[_block].price);
    uint256 amount = tokensPerEth.mul(msg.value).div(1 ether);

   // uint256 amount = msg.value / saleTokens[_block].price;  // price in eth but value in wei :/ (auto conversion)
    amount = amount * 10 ** 18;
    
    balance[msg.sender] = tokens(amount,0,0,_block);
    saleTokens[_block].issued = saleTokens[_block].issued.add(amount);
    require(saleTokens[_block].supply >= saleTokens[_block].issued,"amount exceeds supply");

    totalEthRaised = totalEthRaised.add(msg.value);
    _sendEthAsPerQouta();
    // in case of hardcap reached end the sale.
    if(totalEthRaised >= hardCap){
        _endSale();
    }

    emit Buy(msg.sender,_block,amount);
} 

// to claim & vest tokens
function claim() external returns(uint256) {
// sale & lock period ended, vesting calculation
uint8 _block = balance[msg.sender].blockId;
require(saleEnd && ( saleTokens[_block].lockPeriod + endTime ) < block.timestamp, "vesting isn't started yet");
uint256 unVestedTokens = balance[msg.sender].amount - balance[msg.sender].amountVested;
require( unVestedTokens > 0, "no tokens to vest");


// save last vested time and then caclulate current with it to find how much to be vested now and then update last vested time
// calculate no. hours. obtain 1 hour amount and multiply with total hours

uint256 hour;
uint256 value;
if(balance[msg.sender].lastVestingTime == 0){
     hour = (block.timestamp- (saleTokens[_block].lockPeriod.add(endTime))).div(1 hours);
}else
 hour = (block.timestamp- (balance[msg.sender].lastVestingTime)).div(1 hours);

 require(hour > 0,"not enough time to vest, please try later");
// days to vest
uint256 day = (hour.mul(1 hours)).div(1 days);
// remaining hours to vest
if(day > 0){
     value = perCalc(balance[msg.sender].amount, saleTokens[_block].releasePerDayPerc, saleTokens[_block].releasePerDayDiv);
     value = value.mul(day);
     hour = hour.sub(day.mul(1 days).div(1 hours));
     
}
uint256 valuePerHour;
if(hour > 0){
 valuePerHour = perCalc(balance[msg.sender].amount, saleTokens[_block].releasePerHourPerc, saleTokens[_block].releasePerHourDiv);
  
 value = value.add(valuePerHour.mul(hour));
}
 require(value > 0,"tokens too low to vest");
 // last vesting time update
 balance[msg.sender].lastVestingTime = block.timestamp;

// vested tokens deduct from block's tokens
if(unVestedTokens >= value){
    balance[msg.sender].amountVested = balance[msg.sender].amountVested.add(value);

    // if dust amount left only
    uint256 dust = unVestedTokens - value;
    if(dust < valuePerHour){
        value = value.add(dust);
        balance[msg.sender].amountVested = balance[msg.sender].amountVested.add(dust);
    }
}else{
    value = unVestedTokens;
    balance[msg.sender].amountVested = balance[msg.sender].amountVested.add(unVestedTokens);
}

// add tokens to erc20 supply as vested tokens to be consumed and used as user wants.
erc20Token.transfer(msg.sender, value);
// emit token vested
emit Vesting(msg.sender,value,_block);

return value;
}


function perCalc(uint amount, uint percentage, uint div) pure public returns(uint value){
    value = ( amount * percentage ) / div;
   // require(value > 0, "tokens too low to vest");
    return value;
}
function balanceOfBlock(address account) view external returns(uint _amount,uint _block, uint256 _claimed){
    return (balance[account].amount,balance[account].blockId, balance[account].amountVested);
}

function uniswapEthWithdraw(address payable account) onlyOwner external {
    require(uniswapEth > 0,"no funds to transfer");
    account.transfer(uniswapEth);
    uniswapEth = 0;
}

function ethBalanceOfUniswap( ) view external returns(uint256){
    return uniswapEth;
}
function ethBalanceOfContract( ) view external returns(uint256){
    return address(this).balance;
}
function _sendEthAsPerQouta() internal {

    // transfer raised eth to respective addresses as per quota
    // 67.5% to company wallet, 30% for uniswap, 2.5% for referals
    
        uint256 _ethWithdraw = perCalc(msg.value,675,1000);
                uniswapEth = uniswapEth.add(perCalc(msg.value,30,100));
        uint256 _referalEthReward = perCalc(msg.value,25,1000);

    // transferring eth
    companyWallet.transfer(_ethWithdraw);
    // to referrer and if not then transfer to company wallet
    if(referals[msg.sender] != address(0)){
        // send amount to referal
        referals[msg.sender].transfer(_referalEthReward);

        emit ReferalReward(referals[msg.sender], _referalEthReward);
    }else{
        companyWallet.transfer(_referalEthReward);
        emit ReferalReward(companyWallet, _referalEthReward);
    }

}
function addRefferal(address payable _referee) external {
    require(referals[_referee]== address(0),'referee already exists');
    referals[_referee]= payable(msg.sender);
    emit ReferalAdded(referals[_referee], _referee);
}
function setTokenAddress(address _tokenContract) external onlyOwner {
    erc20Token = IToken(_tokenContract);
    emit TokenContract(erc20Token);
}
// TollBridge for Block#1
function tollBridge() external {

    uint8 _block = balance[msg.sender].blockId;
    require(_block == 1,"tollBridge only available on private block");
    require(saleEnd && ( saleTokens[_block].lockPeriod + endTime ) < block.timestamp, "vesting isn't started yet");
    uint256 unVestedTokens = balance[msg.sender].amount - balance[msg.sender].amountVested;
    require( unVestedTokens > 0, "no tokens to vest");

    require(( saleTokens[3].vestingPeriod + endTime ) > block.timestamp,"block3 already released");

    uint256 value = unVestedTokens.mul(saleTokens[_block].price).div(1 ether); // worth of tokens in pennies
    uint256 value1 = value.div(saleTokens[4].price);
            value1 = value1 * 10 ** 18;
    balance[msg.sender].amountVested = balance[msg.sender].amountVested.add(unVestedTokens);

    erc20Token.transfer(msg.sender, value1);

    emit TollBridge(msg.sender, value1);



}

// creating this function for test purposes to create different vesting scenarios 
function setEndTime(uint256 _time) external onlyOwner {
    endTime = _time;
}


 
event Vesting(address indexed account, uint256 amount, uint8 blockId);
event Buy(address indexed account, uint8 indexed block, uint256 amount);
event Issue(address indexed account,uint256 amount, uint8 indexed block);
event EndSale(uint256 endTime);
event ReferalReward(address indexed to, uint256 amount);
event ReferalAdded(address indexed referer, address referee);
event TokenContract(IToken tokenContract);
event TollBridge(address indexed account, uint256 amount);
}