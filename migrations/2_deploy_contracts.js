let tokenSale = artifacts.require('./TokenSale.sol');

module.exports = function (deployer) {
  let _startTime = Math.floor(new Date().getTime() / 1000);
  let _softCap = web3.utils.toWei('1000');
  let _hardCap = web3.utils.toWei('5000');
  let _minBuy = web3.utils.toWei('100');
  let _maxBuy = web3.utils.toWei('500');
  let _tokenName = 'MOD';
  let _symbol = 'MOD';
  deployer.deploy(tokenSale,_startTime,_softCap,_hardCap,_minBuy,_maxBuy,_tokenName,_symbol);
};
