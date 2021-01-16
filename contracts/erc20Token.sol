// SPDX-License-Identifier: MIT

pragma solidity 0.7.1;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract erc20Token is ERC20, Ownable {

address saleContract;

constructor(string memory _tokenName, string memory _symbol, address _saleContract) ERC20(_tokenName, _symbol) public {
      // mint all blocks tokens at once and transfer to tokenSale contract
      saleContract = _saleContract;
      uint256 _supply = 1600000 * 10 ** 18;
      _mint( saleContract, _supply );
}
// burn function to let sale contract burn all saleable blocks tokens which wasn't purchased
function burn(uint256 _amount) external onlySaleContract returns (bool){

    _burn(msg.sender, _amount);
    return true;
}
modifier onlySaleContract {
    require(msg.sender == saleContract, "only sale contract allowed");
    _;
}
}