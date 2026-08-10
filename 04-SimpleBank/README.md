# SimpleBank

A basic Ethereum smart contract built with Solidity and Foundry.

SimpleBank allows users to deposit ETH, check their deposited balance, and withdraw their funds.

## Features

- Deposit ETH into the contract
- Track individual user balances
- Check a user's deposited balance
- Withdraw deposited ETH
- Prevent users from withdrawing more than their balance
- Support multiple independent users
- Automated smart contract testing with Foundry
- Local blockchain deployment using Anvil
- Contract interaction using Cast
- Deployment using a Foundry deployment script

## Smart Contract

The main contract is:

`src/SimpleBank.sol`

### Functions

#### `deposit()`

Allows users to deposit ETH into the contract.

```solidity
function deposit() public payable
```

#### `balanceOf(address _user)`

Returns the deposited balance of a user.

```solidity
function balanceOf(address _user) public view returns (uint256)
```

#### `withdraw(uint256 _amount)`

Allows users to withdraw their deposited ETH.

The transaction reverts if the user doesn't have enough balance.

## Testing

Tests are located in:

`test/SimpleBank.t.sol`

The project tests:

- ETH deposits
- Multiple deposits
- Withdrawals
- Full balance withdrawal
- Insufficient balance reverts
- Multiple users

Run tests with:

```bash
forge test
```

All 5 tests should pass.

## Foundry Tools

- **Forge** — Build and test smart contracts
- **Anvil** — Local Ethereum blockchain
- **Cast** — Interact with deployed contracts

### Build

```bash
forge build
```

### Test

```bash
forge test
```

### Start Local Blockchain

```bash
anvil
```

### Deploy

The deployment script is:

`script/DeploySimpleBank.s.sol`

Deploy to a local Anvil blockchain with:

```bash
forge script script/DeploySimpleBank.s.sol:DeploySimpleBank \
    --rpc-url http://127.0.0.1:8545 \
    --private-key YOUR_ANVIL_PRIVATE_KEY \
    --broadcast
```

> Never commit or share a real private key.

## Project Structure

```text
SimpleBank/
├── src/
│   └── SimpleBank.sol
├── test/
│   └── SimpleBank.t.sol
├── script/
│   └── DeploySimpleBank.s.sol
├── lib/
│   └── forge-std/
├── broadcast/
├── foundry.toml
└── README.md
```

## Technologies

- Solidity
- Foundry
- Forge
- Anvil
- Cast
- Ethereum / EVM

## Learning Goals

This project was built to practice:

- Solidity mappings
- Payable functions
- `msg.sender`
- `msg.value`
- ETH transfers
- `require` statements
- Smart contract unit testing
- Foundry cheatcodes
- Local blockchain deployment
- Contract interaction using Cast
- Foundry deployment scripts