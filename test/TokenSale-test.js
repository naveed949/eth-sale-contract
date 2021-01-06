const TokenSale = artifacts.require('TokenSale')


contract('TokenSale', accounts => {
const tokenSale;
  before(async () => {
    tokenSale = await TokenSale.new();
  })


  it('Second contract initiated correcly', async () => {
    const name = await token2.name.call()
    assert.equal(name, 'slava\'s sweet token')
    const symbol = await token2.symbol.call()
    assert.equal(symbol, 'nu token')
  })

})
