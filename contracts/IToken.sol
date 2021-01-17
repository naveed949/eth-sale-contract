// SPDX-License-Identifier: MIT

pragma solidity 0.7.1;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IToken {

    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(uint256 _amount) external returns(bool);

}


