const TokenSale = artifacts.require('TokenSale')


contract('TokenSale', accounts => {
let tokenSale; 
    let _startTime = Math.floor(new Date().getTime() / 1000); //seconds
    let _softCap = 1000;
    let _hardCap = 5000;
    let _minBuy = 10;
    let _maxBuy = 50;
    let _wallet = accounts[1];
    let _tokenName = 'myToken';
    let _symbol = 'MT';
  before(async () => {
   
    tokenSale = await TokenSale.new(_startTime,_softCap,_hardCap,_minBuy,_maxBuy,_wallet,_tokenName,_symbol);
  })


  it('contract deployed & initialized', async () => {
    const name = await tokenSale.name.call()
    assert.equal(name, _tokenName)
    const symbol = await tokenSale.symbol.call()
    assert.equal(symbol, _symbol)
  })
  it('Buy Tokens of block#1', async () => {
   // const block = await tokenSale.saleTokens.call(1);
   // console.log(block.price.toString())
    let user = accounts[1];
    let eth = "1.65";
    let tokensPurchased = "11";
    let block = "1";
     await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});

    const balance = await tokenSale.balanceOfBlock.call(user);
    assert.equal(balance._amount.toString(), tokensPurchased)
    assert.equal(balance._block.toString(), block)
  })
  it('Buy Tokens of block#2', async () => {
    let user = accounts[2];
    let eth = "2.4";
    let tokensPurchased = "12";
    let block = "2";
      await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
 
     const balance = await tokenSale.balanceOfBlock.call(user);
     assert.equal(balance._amount.toString(), tokensPurchased)
     assert.equal(balance._block.toString(), block)
   })
   it('Buy Tokens of block#3', async () => {
    let user = accounts[3];
    let eth = "3.25";
    let tokensPurchased = "13";
    let block = "3";
      await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
 
     const balance = await tokenSale.balanceOfBlock.call(user);
     assert.equal(balance._amount.toString(), tokensPurchased)
     assert.equal(balance._block.toString(), block)
   })
   it('Buy Tokens of block#4', async () => {
    let user = accounts[4];
    let eth = "4.2";
    let tokensPurchased = "14";
    let block = "4";
      await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
 
     const balance = await tokenSale.balanceOfBlock.call(user);
     assert.equal(balance._amount.toString(), tokensPurchased)
     assert.equal(balance._block.toString(), block)
   })
   it('One account/wallet can\'t buy tokens from more then one block', async () => {
    let user = accounts[4];
    let eth = "4.2";
    let block = "3";
    let expected = 'buyer already exists'
    let msg;
    try {
      tx = await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
    } catch (error) {
      msg = error.reason;
    }
     assert.equal(expected,msg)
   })
   it('A user can\'t buy tokens below set minimum Buy limit', async () => {
    let user = accounts[5];
    let eth = "1.3";
    let block = "1";
    let expected = 'amount too low'
    let msg;
    try {
      tx = await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
    } catch (error) {
      msg = error.reason;
    }
     assert.equal(expected,msg)
   })
   it('A user can\'t buy more tokens then set maximum Buy limit', async () => {
    let user = accounts[5];
    let eth = "7.65";
    let block = "1";
    let expected = 'amount too high'
    let msg;
    try {
      tx = await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
    } catch (error) {
      msg = error.reason;
    }
     assert.equal(expected,msg)
   })

})