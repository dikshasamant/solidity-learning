// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract SimpleBank {

    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }
}