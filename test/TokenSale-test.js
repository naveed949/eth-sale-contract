const TokenSale = artifacts.require('TokenSale')
const ERC20 = artifacts.require('erc20Token')
const {getTimestamp} = require("./utils/utils.js");

contract('TokenSale', accounts => {
let tokenSale; 
let tokenContract;
    let _startTime = Math.floor(new Date().getTime() / 1000); //seconds
    let _softCap = web3.utils.toWei('10');
    let _hardCap = web3.utils.toWei("100");
    let _minBuy = web3.utils.toWei("0.15");
    let _maxBuy = web3.utils.toWei("80");
    let _companyWallet = accounts[0]
    let _ethPrice = '60000'  // price in Pennies ($ * 100)
    let _tokenName = 'MOD';
    let _symbol = 'MOD';
  before(async () => {
    // first of all deploy salecontract
    tokenSale = await TokenSale.new(_startTime,_softCap,_hardCap,_minBuy,_maxBuy,_companyWallet, _ethPrice);
    // pass salecontract's address to erc20 contract, so it can mint tokens and send to salecontract
    tokenContract = await ERC20.new(_tokenName, _symbol, tokenSale.address)
    
   
  })

  it('token & sale contracts deployed & initialized', async () => {
    // set tokencontract's address in salecontract, so it can manage tokens durring sale
    let tx = await tokenSale.setTokenAddress(tokenContract.address,{from:accounts[0]});
    assert.equal(tx.logs[0].event, 'TokenContract');
    assert.equal(tx.logs[0].args.tokenContract,tokenContract.address)
    const name = await tokenContract.name.call()
    assert.equal(name, _tokenName)
    const symbol = await tokenContract.symbol.call()
    assert.equal(symbol, _symbol)
  })
  it('Issue Tokens of block#1 private block', async () => {
   // const block = await tokenSale.saleTokens.call(1);
   // console.log(block.price.toString())
    let owner = accounts[0]
    let user = [accounts[1]];
    
    let tokens = [web3.utils.toWei("30000")];
    let block = "1";
    let fromWei = web3.utils.fromWei;
    let tx = await tokenSale.issueNonSaleTokens(user, tokens, block,{from: owner});

    assert.equal(tx.logs[0].event, 'Issue');
    assert.equal(tx.logs[0].args.account,user[0])
    assert.equal(tx.logs[0].args.block.toString(),block)
    assert.equal(fromWei(tx.logs[0].args.amount),fromWei(tokens[0]))

    const balance = await tokenSale.balanceOfBlock.call(user[0]);
    assert.equal(web3.utils.fromWei(balance._amount), fromWei(tokens[0]));
    assert.equal(balance._block.toString(), block)
    
  })
  it('Buy Tokens of block#2', async () => {
    let user = accounts[2];
    let eth = "12";
    let tokensPurchased = "36000";
    let block = "2";
    let fromWei = web3.utils.fromWei;
    let tx =  await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});

      assert.equal(tx.logs[0].event, 'ReferalReward');
      assert.equal(tx.logs[0].args.to,_companyWallet)
      console.log(fromWei(tx.logs[0].args.amount)+"::"+(parseInt(eth) * 25)/1000)
      assert.equal(fromWei(tx.logs[0].args.amount),(eth * 25)/1000)


     const balance = await tokenSale.balanceOfBlock.call(user);
     assert.equal(web3.utils.fromWei(balance._amount), tokensPurchased)
     assert.equal(balance._block.toString(), block)
     
   })
   
   it('Buy Tokens of block#3', async () => {
    let user = accounts[3];
    let eth = "20";
    let tokensPurchased = "48000";
    let block = "3";
      await tokenSale.buyTokens(block,{value: web3.utils.toWei(eth),from: user});
 
     const balance = await tokenSale.balanceOfBlock.call(user);
     assert.equal(web3.utils.fromWei(balance._amount), tokensPurchased)
     assert.equal(balance._block.toString(), block)
   })
   it('Buy Tokens of block#4', async () => {
    let user = accounts[4];
    let eth = "18";
    let tokensPurchased = "36000";
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
    let eth = "0.14";
    let block = "2";
    let expected = 'eth sent too low'
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
    let eth = "81";
    let block = "2";
    let expected = 'eth sent too high'
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
    let toWei = web3.utils.toWei;
    let fromWei = web3.utils.fromWei;
    let owner = accounts[0];
    let holders = [accounts[5],accounts[8]];
    let tokens = [toWei("90"),toWei("95")];
    let block = "5";
    let tx = await tokenSale.issueNonSaleTokens(holders,tokens,block,{from: owner});
 
     const balance = await tokenSale.balanceOfBlock.call(holders[0]);
     assert.equal(fromWei(balance._amount), fromWei(tokens[0]))
     const balance1 = await tokenSale.balanceOfBlock.call(holders[1]);
     assert.equal(fromWei(balance1._amount), fromWei(tokens[1]))
     assert.equal(balance._block.toString(), block)
   })
  //  async() =>{
  //    const sleep = (waitTimeInMs) => new Promise(resolve => setTimeout(resolve, waitTimeInMs));
  //  await sleep(200)
  //  }
   
   it('Tokens can\'t be vested before sale ended',async () => {
    
    let user = accounts[4];
    let block = "4";
    let expected = 'vesting isn\'t started yet'
    let msg;
    try {
      tx = await tokenSale.claim({from: user});
    } catch (error) {
      msg = error.reason;
    }
     assert.equal(expected,msg)
   })
   it('Add referal and receiving refaral reward', async () => {
    let refaral = accounts[1];
    let referee = accounts[7];
    let block = "2";
    let eth = web3.utils.toWei('10');
    let tx = await tokenSale.addRefferal(referee,{from: refaral});
    assert.equal(tx.logs[0].event, 'ReferalAdded');
  
    let balance = web3.utils.fromWei(await web3.eth.getBalance(refaral));
    let tx2 = await tokenSale.buyTokens(block,{value: eth, from: referee});
    let balance2 = web3.utils.fromWei(await web3.eth.getBalance(refaral));
  
    let referalReward = web3.utils.fromWei(""+(parseInt(eth) * 25)/1000)
    let sum = parseFloat(balance) + parseFloat(referalReward)
    assert.equal(sum, balance2)
  
   })

   it('End the sale, only owner can end the sale', async () => {
    let owner = accounts[0];
    
/**
 * commenting out this testcase in favour of below test where sale be ended when hardcap reached
 * Not manually
 * 
 */
 /** 
    let tx =  await tokenSale.endSale({from: owner});

    let balance4 = await tokenContract.balanceOf.call(tokenSale.address);
    console.log(web3.utils.fromWei(balance4))

    assert.equal(tx.logs[0].event, 'EndSale')
    */
   })
   it('Sale End when Hardcap reached', async () => {
    // hardcap reach
    let buyer = accounts[9];
    let ethRaised = await tokenSale.totalEthRaised.call();

    console.log(ethRaised.toString())

    let eth = _hardCap - ethRaised;
    let block = 2;
    let tx = await tokenSale.buyTokens(block,{value: eth,from: buyer});

    let ethRaised2 = await tokenSale.totalEthRaised.call();
   // ethRaised2 = web3.utils.fromWei(ethRaised);
    assert.equal(ethRaised2.toString(),_hardCap);
     assert.equal(tx.logs[1].event, 'EndSale')
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
    let holder = [accounts[6]];
    let tokens = [web3.utils.toWei("20")];
    let block = "5";
      await tokenSale.issueNonSaleTokens(holder,tokens,block,{from: owner});
 
     const balance = await tokenSale.balanceOfBlock.call(holder[0]);
     assert.equal(balance._amount.toString(), tokens[0])
     assert.equal(balance._block.toString(), block)
   })
   it('Tokens can\'t be vested before lock period ended', async () => {
    let user = accounts[3];
    let eth = "7.65";
    let block = "3";
    let expected = false
    let msg;
    try {
      tx = await tokenSale.claim({from: user});
    } catch (error) {
      msg = error.reason;
      expected = true
    }
     assert.isTrue(expected)
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

      //  let perc = await tokenSale.perCalc(web3.utils.toWei('60'),41666666667,1000000000000,{from: owner});
      // console.log(web3.utils.fromWei(perc))
      // let tx2r = await tokenSale.getTotalTime(block,{from: holder});
      // console.log(tx2r.hour.toString())
      // console.log(tx2r.day.toString())
      // console.log(tx2r.value.toString())

      let tx = await tokenSale.claim({from: holder});
      console.log(web3.utils.fromWei(tx.logs[0].args.amount))
      assert.equal(tx.logs[0].event, 'Vesting')
      let balance = await tokenContract.balanceOf.call(holder);
    console.log(web3.utils.fromWei(balance))
      assert.equal(web3.utils.fromWei(balance),'36000');
   })
   it('Claiming vested tokens of block#1', async () => {
    
    
    let owner = accounts[0];
    let holder = accounts[1];
    let tokens = "14";
    let block = "1";
    let time = getTimestamp(2021,"01","09","00");

      let tx2 = await tokenSale.setEndTime(time,{from: owner});
      let time2 = await tokenSale.endTime.call();
      assert.equal(time+"", time2.toString());

      // let perc = await tokenSale.perCalc(web3.utils.toWei("50"),1391666667,1000000000000,{from: owner});
      // console.log(web3.utils.fromWei(perc))
      // let tx2r = await tokenSale.getTotalTime(block,{from: holder});
      // console.log(tx2r.hour.toString())
      // console.log(tx2r.day.toString())
      // console.log(tx2r.value.toString())

      let tx = await tokenSale.claim({from: holder});
      console.log(web3.utils.fromWei(tx.logs[0].args.amount))
      assert.equal(tx.logs[0].event, 'Vesting')
      let balance = await tokenContract.balanceOf.call(holder);
      console.log(web3.utils.fromWei(balance))
    //  assert.equal(web3.utils.fromWei(balance),'8016');

   })
   it('Claiming vested tokens of block#5 after 50% vesting period over', async () => {
    
    
    let owner = accounts[0];
    let holder = accounts[5];
    let tokens = "14";
    let block = "5";
  //  let time = getTimestamp(2020,"12","01","13");
    let time = Math.floor(new Date().getTime() / 1000);
    // 30 days lock period + 90 days (50% vesting period)
    const secondsDay = 86400;
    let lockPeriod = 30 * secondsDay;
    let halfVestingPeriod = (180/2) * secondsDay;
    time = time - (lockPeriod + halfVestingPeriod);
    // calculate 50% vesting token amount
    let balance = await tokenSale.balanceOfBlock.call(holder);
    balance = web3.utils.fromWei(balance._amount); 
    
    let vestAmount = await tokenSale.perCalc.call(web3.utils.toWei(balance),5479452055,1000000000000);
    vestAmount = web3.utils.fromWei(vestAmount.mul(web3.utils.toBN("90"))); // 1 day amount
   // vestAmount = vestAmount * (180/2) // 50% vesting amount (90 days)

      let tx2 = await tokenSale.setEndTime(time,{from: owner});
      let time2 = await tokenSale.endTime.call();
      assert.equal(time+"", time2.toString());

      // let perc = await tokenSale.perCalc(web3.utils.toWei("50"),228310502,1000000000000,{from: owner});
      // console.log(web3.utils.fromWei(perc))
      // let tx2r = await tokenSale.getTotalTime(block,{from: holder});
      // console.log(tx2r.hour.toString())
      // console.log(tx2r.day.toString())
      // console.log(tx2r.value.toString())

   let tx = await tokenSale.claim({from: holder});
      console.log(web3.utils.fromWei(tx.logs[0].args.amount))
      assert.equal(tx.logs[0].event, 'Vesting')
      let balance2 = await tokenContract.balanceOf.call(holder);
      console.log(web3.utils.fromWei(balance2))
      assert.equal(vestAmount,web3.utils.fromWei(balance2))

     
})

it('Uniswap liquidity 30.5% ETH , withdrawal(by only owner) for manual uniswap listing', async () => {
  let owner = accounts[0];
  let uniswapLiquidity = accounts[9]
  let ethBalanceOfUniswap = await tokenSale.ethBalanceOfUniswap.call();
  ethBalanceOfUniswap = web3.utils.fromWei(ethBalanceOfUniswap)

  let toWei = web3.utils.toWei;
  let fromWei = web3.utils.fromWei;

  let balance = web3.utils.fromWei(await web3.eth.getBalance(uniswapLiquidity));
  let tx = await tokenSale.uniswapEthWithdraw(uniswapLiquidity,{from: owner});
    let balance2 = web3.utils.fromWei(await web3.eth.getBalance(uniswapLiquidity));
    console.log(fromWei(""+(parseInt(toWei(balance)) + parseInt(toWei(ethBalanceOfUniswap)))) +" :: "+ balance2)
    
    assert.equal(fromWei(""+(parseInt(toWei(balance)) + parseInt(toWei(ethBalanceOfUniswap))))  , balance2)
    
 })
 it('UnSold tokens burnt after sale ended', async () => {
  let owner = accounts[0];
  let withdrawTo = accounts[7];
  let tokens = "14";
  
  // block#1
   let block = await tokenSale.saleTokens.call(1);
   assert.equal(block.supply.toString(), block.issued.toString())
    // block#2
   block = await tokenSale.saleTokens.call(2);
   assert.equal(block.supply.toString(), block.issued.toString())
     // block#3
   block = await tokenSale.saleTokens.call(3);
   assert.equal(block.supply.toString(), block.issued.toString())
       // block#4
   block = await tokenSale.saleTokens.call(4);
   assert.equal(block.supply.toString(), block.issued.toString())
    
 })
 it('Toll Bridge applied on private block', async () => {
  let holder = accounts[1];
  let owner = accounts[0];
  let uniswapLiquidity = accounts[9]
  let privateBlock = await tokenSale.balanceOfBlock.call(holder);
  let endTime = Math.floor(new Date().getTime() / 1000); //seconds
  let toWei = web3.utils.toWei;
  let fromWei = web3.utils.fromWei;

      let unVestedTokens = fromWei(privateBlock._amount.sub(privateBlock._claimed))
      let block1Value = unVestedTokens * 0.15;
      let toBeVested = parseInt(""+(block1Value / 0.30));
      await tokenSale.setEndTime(endTime,{from: owner}); // updating start time
  let tx = await tokenSale.tollBridge({from: holder});
  assert.equal(tx.logs[0].event, 'TollBridge');
  assert.equal(tx.logs[0].args.account, holder)
  assert.equal(fromWei(tx.logs[0].args.amount), toBeVested);

 })


})
