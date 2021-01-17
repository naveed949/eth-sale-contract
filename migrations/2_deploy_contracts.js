let tokenSale = artifacts.require('./TokenSale.sol');
let erc20 = artifacts.require('./erc20Token.sol');

module.exports = async function (deployer) {
  let _startTime = Math.floor(new Date().getTime() / 1000);
  let _softCap = web3.utils.toWei('1000');
  let _hardCap = web3.utils.toWei('5000');
  let _minBuy = web3.utils.toWei('0.1');
  let _maxBuy = web3.utils.toWei('500');
  let _companyWallet = '0x70B570609Fa0eBD2C8af9515504E1d1884081ef9';
  let _ethPrice = '60000'  // price in Pennies ($ * 100)
  let _tokenName = 'MOD';
  let _symbol = 'MOD';
  deployer.deploy(tokenSale,_startTime,_softCap,_hardCap,_minBuy, _maxBuy,
     _companyWallet, _ethPrice).then(_saleContract=>{
       // deployer.deploy(erc20,_tokenName,_symbol, _saleContract);
     })
  
  
};
