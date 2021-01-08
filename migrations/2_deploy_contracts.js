let tokenSale = artifacts.require('./TokenSale.sol');

module.exports = function (deployer) {
  let _startTime = Math.floor(new Date().getTime() / 1000);
  let _softCap = 1000;
  let _hardCap = 5000;
  let _minBuy = 10;
  let _maxBuy = 50;
  let _wallet = '0x16AAA70B36e8d81A70a9004531fF57CA218E3a1A';
  let _tokenName = 'myToken';
  let _symbol = 'MT';
  deployer.deploy(tokenSale,_startTime,_softCap,_hardCap,_minBuy,_maxBuy,_wallet,_tokenName,_symbol);
};
