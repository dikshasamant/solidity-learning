# Multi-Signature Wallet

A 2-of-3 multi-signature Ethereum wallet built with Solidity and Foundry.

This project demonstrates multi-owner access control, transaction submission, confirmation thresholds, confirmation revocation, ETH transfers, low-level calls, and security-focused testing.

## Features

- Multiple wallet owners
- Configurable confirmation threshold
- Owner-only transaction submission
- Owner-only transaction confirmation
- Confirmation revocation
- ETH deposits through `receive()`
- ETH transfers through low-level `call`
- Prevention of duplicate confirmations
- Prevention of double execution
- Protection against unauthorized actions
- Validation of owners and confirmation requirements
- Failed transaction handling with state rollback

## How It Works

This wallet uses a multi-signature approval system.

Example configuration:

- Owners: 3
- Required confirmations: 2

A transaction follows this lifecycle:

1. An owner submits a transaction.
2. Owners confirm the transaction.
3. Once the required number of confirmations is reached, an owner can execute it.
4. The wallet performs the requested transaction.

Example:

    Owner 1 submits transaction
            ↓
    Owner 1 confirms
            ↓
    Owner 2 confirms
            ↓
    2 / 2 confirmations reached
            ↓
    Transaction executes

A single owner cannot execute a transaction without reaching the required confirmation threshold.

## Contract Structure

### Transaction

Each transaction stores:

- `to` — destination address
- `value` — amount of ETH to send
- `data` — optional calldata
- `executed` — whether the transaction has been executed
- `confirmations` — number of owner confirmations

### Owners

The wallet maintains:

- An array of owners
- A mapping for efficient owner verification

### Confirmation Tracking

Confirmations are tracked using:

    transaction index → owner address → confirmed

This prevents the same owner from confirming a transaction more than once.

## Main Functions

### `submitTransaction()`

Allows an owner to create a pending transaction.

### `confirmTransaction()`

Allows an owner to approve a pending transaction.

### `revokeConfirmation()`

Allows an owner to remove their confirmation before execution.

### `executeTransaction()`

Executes a transaction after the required number of confirmations has been reached.

The transaction is marked as executed before the external call:

    transaction.executed = true;

    (bool success, ) = transaction.to.call{value: transaction.value}(
        transaction.data
    );

    require(success, "Transaction failed");

If the external call fails, the entire transaction reverts and the state change is rolled back.

### `getOwners()`

Returns the wallet owners.

### `getTransactionCount()`

Returns the number of submitted transactions.

### `getTransaction()`

Returns the details of a transaction.

## Security Considerations

The contract includes checks for:

- Unauthorized owners
- Duplicate owners
- Zero-address owners
- Invalid confirmation thresholds
- Duplicate confirmations
- Revoking non-existent confirmations
- Executing without enough confirmations
- Executing an already executed transaction
- Confirming an already executed transaction
- Failed external calls

The execution flow follows the Checks-Effects-Interactions pattern by updating the execution state before performing the external call.

## Testing

The project contains **21 Foundry tests** covering successful operations, authorization, confirmation management, transaction execution, constructor validation, and failed external calls.

Test categories include:

- Owner initialization
- Transaction submission
- Owner authorization
- Confirmation
- Duplicate confirmation prevention
- Confirmation revocation
- Execution threshold
- ETH transfers
- Double execution prevention
- Failed transaction handling
- Invalid owner validation
- Duplicate owner validation
- Invalid confirmation requirements

Run the test suite with:

    forge test

Latest result:

    21 tests passed
    0 failed
    0 skipped

## Local Deployment

The contract was deployed locally using Foundry and Anvil.

Network:

    Anvil
    Chain ID: 31337

Deployed contract:

    MultiSigWallet
    0x5FbDB2315678afecb367f032d93F642f64180aa3

Configuration:

    Owners: 3
    Required confirmations: 2

## Live Anvil Demonstration

The deployed wallet was funded with:

    5 ETH

A transaction was submitted to transfer:

    1 ETH

to Owner 3.

The transaction required two confirmations:

    Owner 1 → Confirmed
    Owner 2 → Confirmed
    2 / 2 confirmations reached

The transaction was then executed successfully.

Final wallet balance:

    4 ETH

The recipient received:

    1 ETH

Transaction state after execution:

    Executed: true
    Confirmations: 2

## Tech Stack

- Solidity
- Foundry
- Forge
- Anvil
- Cast
- Git
- GitHub

## Project Structure

    09-MultiSigWallet/
    ├── src/
    │   └── MultiSigWallet.sol
    ├── test/
    │   └── MultiSigWallet.t.sol
    ├── script/
    │   └── DeployMultiSigWallet.s.sol
    ├── broadcast/
    ├── cache/
    ├── foundry.toml
    └── README.md

## Learning Outcomes

Through this project, I practiced:

- Multi-signature wallet architecture
- Multi-owner access control
- Confirmation threshold logic
- Solidity mappings with nested mappings
- Struct-based transaction management
- ETH transfers using low-level calls
- Checks-Effects-Interactions
- Revert behavior and state rollback
- Foundry unit testing
- Security and edge-case testing
- Anvil local blockchain deployment
- Cast contract interaction