const TokenSale = artifacts.require('TokenSale')
const {getTimestamp} = require("./utils/utils.js");

contract('TokenSale', accounts => {
let tokenSale; 
    let _startTime = Math.floor(new Date().getTime() / 1000); //seconds
    let _softCap = web3.utils.toWei('1000');
    let _hardCap = web3.utils.toWei("5000");
    let _minBuy = web3.utils.toWei("50");
    let _maxBuy = web3.utils.toWei("500");
    let _wallet = accounts[1];
    let _tokenName = 'MOD';
    let _symbol = 'MOD';
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
    let eth = "7.5";
    let tokensPurchased = "50";
    let block = "1";
     await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});

    const balance = await tokenSale.balanceOfBlock.call(user);
    assert.equal(web3.utils.fromWei(balance._amount), tokensPurchased)
    assert.equal(balance._block.toString(), block)
    
  })
  it('Buy Tokens of block#2', async () => {
    let user = accounts[2];
    let eth = "12";
    let tokensPurchased = "60";
    let block = "2";
      await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
 
     const balance = await tokenSale.balanceOfBlock.call(user);
     assert.equal(web3.utils.fromWei(balance._amount), tokensPurchased)
     assert.equal(balance._block.toString(), block)
   })
   it('Buy Tokens of block#3', async () => {
    let user = accounts[3];
    let eth = "20";
    let tokensPurchased = "80";
    let block = "3";
      await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
 
     const balance = await tokenSale.balanceOfBlock.call(user);
     assert.equal(web3.utils.fromWei(balance._amount), tokensPurchased)
     assert.equal(balance._block.toString(), block)
   })
   it('Buy Tokens of block#4', async () => {
    let user = accounts[4];
    let eth = "18";
    let tokensPurchased = "60";
    let block = "4";
      await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
 
     const balance = await tokenSale.balanceOfBlock.call(user);
     assert.equal(web3.utils.fromWei(balance._amount), tokensPurchased)
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
    let eth = "75.5";
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
   it('User can\'t buy tokens from invalid block e.g except 1-4 saleable blocks', async () => {
    let user = accounts[6];
    let eth = "7.65";
    let block = "5";
    let expected = 'invalid block'
    let msg;
    try {
      tx = await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
    } catch (error) {
      msg = error.reason;
    }
     assert.equal(expected,msg)
   })
   it('Issue tokens from nonSaleable adviser block, only owner can issue', async () => {
    let owner = accounts[0];
    let holder = accounts[5];
    let tokens = "90";
    let block = "5";
      await tokenSale.issueNonSaleTokens(holder,web3.utils.toWei(tokens),block,{from: owner});
 
     const balance = await tokenSale.balanceOfBlock.call(holder);
     assert.equal(web3.utils.fromWei(balance._amount), tokens)
     assert.equal(balance._block.toString(), block)
   })
   it('Tokens can\'t be vested before sale ending', async () => {
    let user = accounts[4];
    let eth = "7.65";
    let block = "4";
    let expected = 'vesting isn\'t started yet'
    let msg;
    try {
      tx = await tokenSale.claim(block,{from: user});
    } catch (error) {
      msg = error.reason;
    }
     assert.equal(expected,msg)
   })

   it('End the sale, only owner can end the sale', async () => {
    let owner = accounts[0];
    
     let tx =  await tokenSale.endSale({from: owner});

     assert.equal(tx.logs[0].event, 'EndSale')
   })
   it('Tokens can\'t be bought after sale ended or before sale started', async () => {
    let user = accounts[6];
    let eth = "7.65";
    let block = "4";
    let expected = 'sale ended'
    let msg;
    try {
      tx = await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
    } catch (error) {
      msg = error.reason;
    }
     assert.equal(expected,msg)
   })
   it('Tokens can be issued from nonSaleable blocks after sale ended, only owner can add new users', async () => {
    let owner = accounts[0];
    let holder = accounts[6];
    let tokens = "20";
    let block = "6";
      await tokenSale.issueNonSaleTokens(holder,tokens,block,{from: owner});
 
     const balance = await tokenSale.balanceOfBlock.call(holder);
     assert.equal(balance._amount.toString(), tokens)
     assert.equal(balance._block.toString(), block)
   })
   it('Tokens can\'t be vested before lock period ended', async () => {
    let user = accounts[3];
    let eth = "7.65";
    let block = "3";
    let expected = 'vesting isn\'t started yet'
    let msg;
    try {
      tx = await tokenSale.claim(block,{from: user});
    } catch (error) {
      msg = error.reason;
    }
     assert.equal(expected,msg)
   })
   it('Claiming vested tokens of block#4', async () => {
    
    
    let owner = accounts[0];
    let holder = accounts[4];
    let tokens = "14";
    let block = "4";
    let time = getTimestamp(2021,"01","09","13");

      let tx2 = await tokenSale.setEndTime(time,{from: owner});
      // let time2 = await tokenSale.endTime.call();
      // assert.equal(time+"", time2.toString());

       let perc = await tokenSale.perCalc(web3.utils.toWei('60'),41666666667,1000000000000,{from: owner});
      console.log(web3.utils.fromWei(perc))
      let tx2r = await tokenSale.getTotalTime(block,{from: holder});
      console.log(tx2r.hour.toString())
      console.log(tx2r.day.toString())
      console.log(tx2r.value.toString())

      let tx = await tokenSale.claim(block,{from: holder});
      console.log(web3.utils.fromWei(tx.logs[1].args.amount))
      console.log(tx.logs[0].args.value.toString())
      assert.equal(tx.logs[1].event, 'Vesting')
      assert.equal(tx.logs[0].event, 'Transfer')
   })
   it('Claiming vested tokens of block#1', async () => {
    
    
    let owner = accounts[0];
    let holder = accounts[1];
    let tokens = "14";
    let block = "1";
    let time = getTimestamp(2021,"01","09","13");

      let tx2 = await tokenSale.setEndTime(time,{from: owner});
      let time2 = await tokenSale.endTime.call();
      assert.equal(time+"", time2.toString());

      let perc = await tokenSale.perCalc(web3.utils.toWei("50"),1391666667,1000000000000,{from: owner});
      console.log(web3.utils.fromWei(perc))
      let tx2r = await tokenSale.getTotalTime(block,{from: holder});
      console.log(tx2r.hour.toString())
      console.log(tx2r.day.toString())
      console.log(tx2r.value.toString())

      let tx = await tokenSale.claim(block,{from: holder});
      console.log(web3.utils.fromWei(tx.logs[1].args.amount))
      console.log(tx.logs[0].args.value.toString())
      assert.equal(tx.logs[1].event, 'Vesting')
      assert.equal(tx.logs[0].event, 'Transfer')
   })
   it('Claiming vested tokens of block#5', async () => {
    
    
    let owner = accounts[0];
    let holder = accounts[1];
    let tokens = "14";
    let block = "5";
    let time = getTimestamp(2021,"01","09","13");

      let tx2 = await tokenSale.setEndTime(time,{from: owner});
      let time2 = await tokenSale.endTime.call();
      assert.equal(time+"", time2.toString());

      let perc = await tokenSale.perCalc(web3.utils.toWei("50"),228310502,1000000000000,{from: owner});
      console.log(web3.utils.fromWei(perc))
      let tx2r = await tokenSale.getTotalTime(block,{from: holder});
      console.log(tx2r.hour.toString())
      console.log(tx2r.day.toString())
      console.log(tx2r.value.toString())
try {
   let tx = await tokenSale.claim(block,{from: holder});
      console.log(web3.utils.fromWei(tx.logs[1].args.amount))
      console.log(tx.logs[0].args.value.toString())
      assert.equal(tx.logs[1].event, 'Vesting')
      assert.equal(tx.logs[0].event, 'Transfer')
} catch (error) {
  console.log(error.reason)
  assert.equal(error.reason,'vesting isn\'t started yet')
}
     
   })

})
