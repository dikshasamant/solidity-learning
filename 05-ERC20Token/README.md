# ERC20Token

A custom ERC-20 style token implementation built from scratch using Solidity and Foundry.

This project implements the core mechanics of an ERC-20 token, including balances, transfers, allowances, minting, burning, ownership, and standard ERC-20 events. The contract was fully tested using Foundry and deployed locally to an Anvil blockchain for real EVM interaction using Cast.

## Features

- ERC-20 style token implementation
- Token name, symbol, and decimals
- Balance tracking
- Total supply tracking
- Token transfers
- Token approvals and allowances
- `transferFrom()` functionality
- Owner-only token minting
- Token burning
- `Transfer` events
- `Approval` events
- Input validation and revert conditions
- Automated Foundry testing
- Local deployment using Anvil
- Contract interaction using Foundry Cast

## Token Details

| Property | Value |
|---|---|
| Name | Diksha Token |
| Symbol | DIK |
| Decimals | 18 |
| Initial Supply | 1000 DIK |

## Smart Contract

The main contract is:

`src/ERC20Token.sol`

### Core Functions

#### `balanceOf(address)`

Returns the token balance of a specific address.

```solidity
function balanceOf(address _user) public view returns (uint256)
```

#### `transfer(address, uint256)`

Transfers tokens from the caller to another address.

The function checks that the sender has enough tokens and that the recipient is not the zero address.

```solidity
function transfer(address _to, uint256 _amount) public returns (bool)
```

#### `approve(address, uint256)`

Allows another address to spend a specified amount of the caller's tokens.

```solidity
function approve(address _spender, uint256 _amount) public returns (bool)
```

#### `allowance(address, address)`

Returns the amount a spender is currently allowed to spend on behalf of a token owner.

```solidity
function allowance(address _owner, address _spender) public view returns (uint256)
```

#### `transferFrom(address, address, uint256)`

Allows an approved spender to transfer tokens from another user's balance.

The function checks both the owner's balance and the spender's allowance.

```solidity
function transferFrom(
    address _from,
    address _to,
    uint256 _amount
) public returns (bool)
```

#### `mint(address, uint256)`

Creates new tokens and assigns them to the specified address.

Only the contract owner can call this function.

```solidity
function mint(address _to, uint256 _amount) public
```

#### `burn(uint256)`

Destroys tokens from the caller's balance and decreases the total supply.

```solidity
function burn(uint256 _amount) public
```

#### `totalSupply()`

Returns the current total token supply.

```solidity
function totalSupply() public view returns (uint256)
```

## Events

The contract implements the standard ERC-20 style events.

### Transfer

Emitted when tokens are transferred, minted, or burned.

```solidity
event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
);
```

Minting uses the zero address as the sender:

```text
address(0) → recipient
```

Burning uses the zero address as the recipient:

```text
holder → address(0)
```

### Approval

Emitted when a token owner approves a spender.

```solidity
event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
);
```

## Testing

The project uses Foundry for automated smart contract testing.

The test suite covers:

- Successful token transfers
- Insufficient balance
- Transfer events
- Token approvals
- `transferFrom()`
- Allowance exceeded
- Token minting
- Owner-only minting
- Token burning
- Insufficient balance during burning
- Mint events
- Burn events

### Test Result

```text
12 tests passed
0 failed
0 skipped
```

Run the tests with:

```bash
forge test
```

## Build

Compile the project with:

```bash
forge build
```

The project builds successfully without compiler or ERC-20 lint warnings.

## Local Deployment

The contract was deployed locally using Foundry and Anvil.

Start a local Anvil blockchain:

```bash
anvil
```

Then deploy using:

```bash
forge script script/DeployERC20Token.s.sol:DeployERC20Token \
--rpc-url http://127.0.0.1:8545 \
--broadcast \
--private-key <ANVIL_PRIVATE_KEY>
```

## Deployment

Local deployment details:

```text
Network: Anvil
Chain ID: 31337

Contract:
ERC20Token

Contract Address:
0x5FbDB2315678afecb367f032d93F642f64180aa3
```

## Contract Interaction with Cast

The deployed contract was queried using Foundry Cast.

### Read Token Name

```bash
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
"name()(string)" \
--rpc-url http://127.0.0.1:8545
```

Result:

```text
"Diksha Token"
```

### Read Symbol

```bash
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
"symbol()(string)" \
--rpc-url http://127.0.0.1:8545
```

Result:

```text
"DIK"
```

### Read Decimals

```bash
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
"decimals()(uint8)" \
--rpc-url http://127.0.0.1:8545
```

Result:

```text
18
```

### Read Total Supply

```bash
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
"totalSupply()(uint256)" \
--rpc-url http://127.0.0.1:8545
```

Result:

```text
1000
```

## On-Chain Interaction

The deployed contract was also tested using actual transactions on Anvil.

### Transfer

100 DIK was transferred from the deployer to another Anvil account.

```text
Before:
Deployer = 1000 DIK
Alice    = 0 DIK

After:
Deployer = 900 DIK
Alice    = 100 DIK
```

### Approval

Alice approved Bob to spend 50 DIK on her behalf.

```text
Alice balance = 100 DIK
Bob allowance = 50 DIK
```

### transferFrom

Bob used his allowance to transfer 30 DIK from Alice to the deployer.

```text
Before:
Alice     = 100 DIK
Deployer  = 900 DIK
Allowance = 50 DIK

After:
Alice     = 70 DIK
Deployer  = 930 DIK
Allowance = 20 DIK
```

The total supply remained:

```text
1000 DIK
```

because transfers do not create or destroy tokens.

## Project Structure

```text
05-ERC20Token/
├── src/
│   └── ERC20Token.sol
├── test/
│   └── ERC20Token.t.sol
├── script/
│   └── DeployERC20Token.s.sol
├── lib/
│   └── forge-std/
├── foundry.toml
├── foundry.lock
├── .gitignore
└── README.md
```

## Technologies

- Solidity
- Foundry
- Forge
- Anvil
- Cast
- Ethereum Virtual Machine (EVM)

## Learning Objectives

This project was built to understand ERC-20 token mechanics from the ground up rather than relying on an existing token implementation.

Key concepts practiced:

- Solidity mappings
- Nested mappings
- State variables
- Constructors
- Events
- `msg.sender`
- Access control
- `require`
- Token balances
- Allowances
- Token transfers
- Minting and burning
- Foundry testing
- Deployment scripts
- Local EVM networks
- Transaction broadcasting
- Contract interaction using Cast
- Reading on-chain state
- Sending state-changing transactions