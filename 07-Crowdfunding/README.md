# Crowdfunding

A decentralized crowdfunding smart contract built from scratch using Solidity and Foundry.

This project allows users to create crowdfunding campaigns, contribute ETH, withdraw funds when a campaign successfully reaches its goal, and receive refunds when a campaign fails.

The contract was tested using Foundry and deployed locally to an Anvil blockchain for EVM interaction using Foundry Cast.

## Features

- Create crowdfunding campaigns
- Set campaign funding goals
- Set campaign deadlines
- Accept ETH contributions
- Track total campaign funding
- Track individual contributor balances
- Successful campaign withdrawals
- Failed campaign refunds
- Prevent duplicate withdrawals
- Prevent duplicate refunds
- Deadline enforcement
- Creator-only withdrawals
- Campaign existence validation
- Campaign state tracking
- Events for major state changes
- Automated Foundry testing
- Local deployment using Anvil
- Contract interaction using Foundry Cast

## Smart Contract

The main contract is:

src/Crowdfunding.sol

### Campaign Structure

Each campaign stores:

    struct Campaign {
        address creator;
        uint256 goal;
        uint256 pledged;
        uint256 deadline;
        bool exists;
        bool withdrawn;
    }

The contract stores campaigns using:

    mapping(uint256 => Campaign) public campaigns;

Individual contributions are tracked using a nested mapping:

    mapping(uint256 => mapping(address => uint256)) public contributions;

This allows the contract to track how much each address contributed to each campaign.

## Core Functions

### createCampaign(uint256 _goal, uint256 _duration)

Creates a new crowdfunding campaign.

Parameters:

- _goal - Amount of ETH required for the campaign
- _duration - Campaign duration in seconds

The campaign deadline is calculated using:

    block.timestamp + _duration

Each campaign receives a unique ID starting from 1.

Example:

    crowdfunding.createCampaign(1 ether, 7 days);

### contribute(uint256 _campaignId)

Allows users to contribute ETH to an active campaign.

The function:

1. Checks that the campaign exists.
2. Checks that the deadline has not passed.
3. Checks that the contribution is greater than zero.
4. Adds the contribution to the campaign's total pledged amount.
5. Records the contributor's individual contribution.

Example:

    crowdfunding.contribute{value: 0.5 ether}(1);

### withdrawFunds(uint256 _campaignId)

Allows the campaign creator to withdraw funds after the campaign deadline if the funding goal was reached.

The function verifies:

- Campaign exists
- Caller is the campaign creator
- Deadline has passed
- Goal was reached
- Funds have not already been withdrawn

The contract uses a state update before the external ETH transfer to follow the Checks-Effects-Interactions pattern.

The withdrawn state is updated before the ETH transfer, helping prevent repeated withdrawals and reentrancy-related issues.

### refund(uint256 _campaignId)

Allows contributors to recover their ETH when a campaign fails to reach its funding goal.

The function verifies:

- Campaign exists
- Deadline has passed
- Funding goal was not reached
- Contributor has an outstanding contribution

The contributor's recorded balance is set to zero before the ETH transfer.

The campaign's pledged amount is also reduced by the refunded contribution.

This prevents a contributor from repeatedly claiming the same contribution.

## Events

The contract emits events for important state changes.

### CampaignCreated

    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed creator,
        uint256 goal,
        uint256 deadline
    );

### Contribution

    event Contribution(
        uint256 indexed campaignId,
        address indexed contributor,
        uint256 amount
    );

### FundsWithdrawn

    event FundsWithdrawn(
        uint256 indexed campaignId,
        address indexed creator,
        uint256 amount
    );

### Refunded

    event Refunded(
        uint256 indexed campaignId,
        address indexed contributor,
        uint256 amount
    );

## Crowdfunding Flow

A successful campaign follows:

    Creator
       |
       | createCampaign()
       v
    Campaign
       |
       | Users contribute ETH
       v
    Goal reached
       |
       | Deadline passes
       v
    Creator calls withdrawFunds()
       |
       v
    Creator receives ETH

A failed campaign follows:

    Creator
       |
       | createCampaign()
       v
    Campaign
       |
       | Users contribute ETH
       v
    Goal NOT reached
       |
       | Deadline passes
       v
    Contributors call refund()
       |
       v
    Contributors receive ETH back

## Testing

The project uses Foundry for automated smart contract testing.

The test suite covers:

- Campaign creation
- ETH contributions
- Successful campaign withdrawal
- Failed campaign refunds
- Contributions after the deadline
- Withdrawal when the funding goal was not reached
- Refunds when the funding goal was reached

### Test Result

    7 tests passed
    0 failed
    0 skipped

Run the tests with:

    forge test

## Build

Compile the project with:

    forge build

The project builds successfully.

Foundry reports block.timestamp lint warnings because campaign deadlines rely on block timestamps. These are lint warnings rather than compilation errors.

## Local Deployment

The contract can be deployed locally using Foundry and Anvil.

Start a local Anvil blockchain:

    anvil

Deploy using:

    forge script script/DeployCrowdfunding.s.sol:DeployCrowdfunding \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast \
    --private-key <ANVIL_PRIVATE_KEY>

## Deployment

The contract was successfully deployed to a local Anvil blockchain.

    Network: Anvil
    Chain ID: 31337

    Contract:
    Crowdfunding

    Contract Address:
    0x5FbDB2315678afecb367f032d93F642f64180aa3

The deployment transaction was successfully broadcast to the local EVM.

## Contract Interaction with Cast

The deployed contract can be interacted with using Foundry Cast.

### Check Campaign Count

    cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
    "campaignCount()(uint256)" \
    --rpc-url http://127.0.0.1:8545

### Create a Campaign

The following creates a campaign with a 1 ETH goal and a 7-day duration:

    cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
    "createCampaign(uint256,uint256)" \
    1000000000000000000 \
    604800 \
    --rpc-url http://127.0.0.1:8545 \
    --private-key <ANVIL_PRIVATE_KEY>

### Read Campaign Data

    cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
    "campaigns(uint256)(address,uint256,uint256,uint256,bool,bool)" \
    1 \
    --rpc-url http://127.0.0.1:8545

The returned values represent:

    creator
    goal
    pledged
    deadline
    exists
    withdrawn

## Project Structure

    07-Crowdfunding/
    ├── src/
    │   └── Crowdfunding.sol
    ├── test/
    │   └── Crowdfunding.t.sol
    ├── script/
    │   └── DeployCrowdfunding.s.sol
    ├── lib/
    │   └── forge-std/
    ├── foundry.toml
    ├── foundry.lock
    ├── .gitignore
    └── README.md

## Technologies

- Solidity
- Foundry
- Forge
- Anvil
- Cast
- Ethereum Virtual Machine (EVM)

## Security Concepts Practiced

This project introduced several important Solidity security concepts:

- Checks-Effects-Interactions
- External ETH transfers
- Reentrancy considerations
- State updates before external calls
- Access control
- Deadline validation
- Double-withdrawal prevention
- Double-refund prevention
- ETH accounting
- Nested mappings
- Payable functions
- Low-level call for ETH transfers

## Learning Objectives

This project was built to understand how a basic crowdfunding protocol works at the smart contract level.

Key concepts practiced:

- Solidity structs
- Mappings
- Nested mappings
- msg.sender
- msg.value
- block.timestamp
- payable
- ETH transfers
- call
- Events
- Access control
- State management
- Checks-Effects-Interactions
- Reentrancy considerations
- Foundry testing
- Foundry cheatcodes
- vm.prank
- vm.deal
- vm.warp
- Deployment scripts
- Local EVM networks
- Transaction broadcasting
- Contract interaction using Cast