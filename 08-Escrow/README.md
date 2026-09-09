# Freelance Escrow Smart Contract

A decentralized freelance escrow smart contract built with Solidity and Foundry. The contract allows a client to create an escrow agreement, fund it with ETH, track the work through defined states, release payment to the freelancer after approval, or refund the client after the deadline.

## Overview

The contract acts as a trust-minimized escrow between a client and freelancer.

Instead of the client sending payment directly to the freelancer, the ETH is held by the smart contract until the agreed conditions are met.

### Participants

- **Client** — creates and funds the escrow
- **Freelancer** — starts and submits the work
- **Escrow Contract** — securely holds and releases the ETH

## Escrow State Machine

CREATED
   |
   | fundEscrow()
   v
FUNDED
   |
   | startWork()
   v
IN_PROGRESS
   |
   | submitWork()
   v
COMPLETED
   |
   | approveWork()
   v
RELEASED
   |
   +----> ETH released to freelancer

FUNDED / IN_PROGRESS
        |
        | deadline passes
        | refundEscrow()
        v
REFUNDED
        |
        +----> ETH returned to client

## Features

- Create freelance escrow agreements
- Store client, freelancer, payment amount, deadline, and escrow state
- Client-only escrow funding
- Exact ETH funding validation
- Freelancer-only work initiation
- Freelancer-only work submission
- Client-only work approval
- ETH release to freelancer
- Deadline-based refunds to the client
- State-machine based workflow
- Access-control validation
- Checks-Effects-Interactions pattern
- Safe ETH transfers using `.call`
- Comprehensive Foundry test suite

## Smart Contract Functions

### `createEscrow()`

Creates a new escrow agreement.

Requirements:

- Freelancer address cannot be the zero address
- Escrow amount must be greater than zero
- Deadline must be in the future

Initial state:

CREATED

### `fundEscrow()`

Allows the client to deposit the exact agreed amount of ETH.

Requirements:

- Caller must be the client
- Escrow must be in `CREATED`
- Sent ETH must exactly equal the agreed amount

State transition:

CREATED → FUNDED

### `startWork()`

Allows the freelancer to begin the work.

Requirements:

- Caller must be the freelancer
- Escrow must be `FUNDED`

State transition:

FUNDED → IN_PROGRESS

### `submitWork()`

Allows the freelancer to submit the completed work.

Requirements:

- Caller must be the freelancer
- Escrow must be `IN_PROGRESS`

State transition:

IN_PROGRESS → COMPLETED

### `approveWork()`

Allows the client to approve completed work.

Requirements:

- Caller must be the client
- Escrow must be `COMPLETED`

The escrow state is changed to `RELEASED` before the external ETH transfer.

State transition:

COMPLETED → RELEASED

The agreed ETH is then transferred to the freelancer.

### `refundEscrow()`

Allows the client to reclaim the escrowed ETH after the deadline.

Requirements:

- Escrow must be `FUNDED` or `IN_PROGRESS`
- Deadline must have passed
- Caller must be the client

State transition:

FUNDED / IN_PROGRESS → REFUNDED

The agreed ETH is then returned to the client.

## Security Considerations

The contract includes several basic smart-contract security practices.

### Access Control

Functions verify that only the appropriate participant can perform sensitive actions.

- Only the client can fund an escrow
- Only the freelancer can start work
- Only the freelancer can submit work
- Only the client can approve work
- Only the client can request a refund

### Checks-Effects-Interactions

State changes are performed before external ETH transfers.

For example, `approveWork()` changes the escrow state to `RELEASED` before transferring ETH to the freelancer.

This helps reduce reentrancy risk.

### ETH Transfer

ETH is transferred using the low-level `.call` pattern, and the return value is checked to ensure the transfer succeeds.

## Testing

The project includes **20 Foundry tests** covering both successful and failing scenarios.

### Tested Functionality

- Escrow creation
- Invalid freelancer address
- Zero escrow amount
- Past deadline
- Correct escrow funding
- Non-client funding attempt
- Incorrect funding amount
- Starting work
- Starting work before funding
- Non-freelancer starting work
- Submitting work
- Submitting work before work starts
- Non-freelancer submitting work
- Approving completed work
- Approving before completion
- Non-client approval attempt
- Successful refund
- Refund before deadline
- Non-client refund attempt
- Refund after funds were already released

Run the test suite with:

`forge test`

Current result:

20 passed
0 failed

## Local Deployment

The contract was deployed and tested locally using Anvil.

### Framework

- Solidity
- Foundry
- Forge
- Anvil
- Cast

### Local Network

- Network: Anvil
- Chain ID: 31337
- RPC URL: `http://127.0.0.1:8545`

### Deployed Contract

`0x5FbDB2315678afecb367f032d93F642f64180aa3`

### Local Deployment Flow

The deployed contract was interacted with using `cast`.

The complete successful lifecycle was verified on the deployed contract:

CREATED
→ FUNDED
→ IN_PROGRESS
→ COMPLETED
→ RELEASED

The final ETH transfer to the freelancer was also verified using `cast balance`.

## Project Structure

08-Escrow/
├── src/
│   └── Escrow.sol
├── test/
│   └── Escrow.t.sol
├── foundry.toml
├── README.md
└── lib/

## How to Run

Clone the repository and enter the project directory:

`cd 08-Escrow`

Build the project:

`forge build`

Run the tests:

`forge test`

Start a local Anvil blockchain:

`anvil`

Deploy the contract:

`forge create src/Escrow.sol:Escrow --rpc-url http://127.0.0.1:8545 --private-key <ANVIL_PRIVATE_KEY> --broadcast`

## What I Learned

This project strengthened my understanding of:

- Solidity structs and enums
- State-machine design
- Ethereum payable functions
- `msg.sender` and `msg.value`
- ETH custody inside smart contracts
- Access control
- Deadline-based logic
- Checks-Effects-Interactions
- Safe ETH transfers
- Foundry unit testing
- Foundry cheatcodes such as `vm.prank`, `vm.deal`, and `vm.warp`
- Local blockchain deployment with Anvil
- Contract interaction using Cast
- Testing both happy paths and failure conditions

## Future Improvements

Possible future improvements include:

- Milestone-based payments
- Dispute resolution
- Multi-signature dispute handling
- Custom Solidity errors
- Events for funding, work submission, approval, release, and refund
- More advanced security testing
- Frontend integration with a Web3 application

## Tech Stack

- **Solidity**
- **Foundry**
- **Forge**
- **Anvil**
- **Cast**
- **Ethereum / EVM**