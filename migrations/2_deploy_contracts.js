let tokenSale = artifacts.require('./TokenSaleContract.sol');

module.exports = function (deployer) {
  deployer.deploy(tokenSale);
};
