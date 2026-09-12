// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;

    uint256 public required;

    Transaction[] public transactions;

    mapping(uint256 => mapping(address => bool)) public confirmed;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "No owners");
        require(_required > 0, "Invalid requirement");
        require(_required <= _owners.length, "Requirement exceeds owners");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {}

    function submitTransaction(address _to, uint256 _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false, confirmations: 0}));
    }

    function confirmTransaction(uint256 _txIndex) external onlyOwner {
        Transaction storage transaction = transactions[_txIndex];

        require(!transaction.executed, "Already executed");
        require(!confirmed[_txIndex][msg.sender], "Already confirmed");

        confirmed[_txIndex][msg.sender] = true;
        transaction.confirmations++;
    }

    function revokeConfirmation(uint256 _txIndex) external onlyOwner {
        Transaction storage transaction = transactions[_txIndex];

        require(!transaction.executed, "Already executed");
        require(confirmed[_txIndex][msg.sender], "Not confirmed");

        confirmed[_txIndex][msg.sender] = false;
        transaction.confirmations--;
    }

    function executeTransaction(uint256 _txIndex) external onlyOwner {
        Transaction storage transaction = transactions[_txIndex];

        require(!transaction.executed, "Already executed");
        require(transaction.confirmations >= required, "Not enough confirmations");

        transaction.executed = true;

        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);

        require(success, "Transaction failed");
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 _txIndex)
        external
        view
        returns (address to, uint256 value, bytes memory data, bool executed, uint256 confirmations)
    {
        Transaction storage transaction = transactions[_txIndex];

        return (transaction.to, transaction.value, transaction.data, transaction.executed, transaction.confirmations);
    }
}
