# SimpleStaking

A simple ETH staking smart contract built from scratch using Solidity and Foundry.

This project demonstrates how users can stake ETH, earn time-based rewards, withdraw their stake, and claim accumulated rewards. The contract also implements reward accounting for multiple deposits and partial withdrawals.

## Features

- ETH staking
- ETH withdrawals
- Time-based staking rewards
- Reward calculation based on staking duration
- Reward claiming
- Multiple deposits
- Partial withdrawals
- Reward accounting
- Events for staking, withdrawals, and reward claims
- Input validation and revert conditions
- Automated Foundry testing
- Local deployment using Anvil
- Contract interaction using Foundry Cast

## Reward System

The contract uses a fixed annual reward rate of 10%.

The reward is calculated based on:

```text
reward = staked amount × reward rate × time staked
         --------------------------------------
                    100 × 365 days
```

For example, if a user stakes 1 ETH for one year:

```text
1 ETH × 10% × 1 year = 0.1 ETH
```

Rewards are accrued whenever a user's staking position changes or when they claim their rewards.

## Reward Accounting

The contract uses:

- `stakedBalance` — tracks how much ETH each user has staked.
- `rewardBalance` — stores rewards already accrued by each user.
- `lastUpdateTime` — records the last timestamp at which rewards were calculated.

Before a user's stake changes, the contract first calculates the reward earned up to that point.

This prevents newly deposited ETH from receiving rewards for time before it was deposited.

For example:

```text
Day 0
Alice stakes 1 ETH

Day 100
Alice stakes another 1 ETH

Day 200
Alice claims
```

The first 1 ETH earns rewards for 200 days.

The second 1 ETH earns rewards for 100 days.

The contract does not incorrectly treat both deposits as having existed since Day 0.

## Partial Withdrawals

The contract also accounts for partial withdrawals.

Example:

```text
Day 0
Alice stakes 2 ETH

Day 100
Alice withdraws 1 ETH

Day 200
Alice claims rewards
```

The first 100 days calculate rewards using 2 ETH.

The next 100 days calculate rewards using the remaining 1 ETH.

This is handled by accruing rewards before changing the user's staking balance.

## Smart Contract

The main contract is:

`src/SimpleStaking.sol`

### `stake()`

Allows a user to deposit ETH into the staking contract.

```solidity
function stake() public payable
```

The function:

- Requires the deposited amount to be greater than zero.
- Accrues any previously earned rewards.
- Adds the deposited ETH to the user's staking balance.
- Updates the total amount staked.
- Emits a `Staked` event.

### `withdraw(uint256)`

Allows a user to withdraw part or all of their staked ETH.

```solidity
function withdraw(uint256 _amount) public
```

The function:

- Requires a valid withdrawal amount.
- Checks that the user has enough staked ETH.
- Accrues rewards before changing the balance.
- Reduces the user's staking balance.
- Sends ETH back to the user.
- Emits a `Withdrawn` event.

### `calculateReward(address)`

Calculates the user's currently accumulated reward.

```solidity
function calculateReward(address _user)
    public
    view
    returns (uint256)
```

The calculation uses the user's:

- Current staked balance
- Reward rate
- Time elapsed since the last reward update
- Previously accumulated rewards

### `claimReward()`

Allows a user to claim their accumulated reward.

```solidity
function claimReward() public
```

The function:

- Accrues the user's latest reward.
- Checks that a reward exists.
- Checks that the contract has enough ETH.
- Resets the user's reward balance.
- Transfers the reward to the user.
- Emits a `RewardClaimed` event.

## Events

The contract emits three events.

### Staked

```solidity
event Staked(address indexed user, uint256 amount);
```

Emitted when a user stakes ETH.

### Withdrawn

```solidity
event Withdrawn(address indexed user, uint256 amount);
```

Emitted when a user withdraws ETH.

### RewardClaimed

```solidity
event RewardClaimed(address indexed user, uint256 reward);
```

Emitted when a user claims staking rewards.

## Testing

The project uses Foundry for automated smart contract testing.

The test suite covers:

- Successful staking
- Zero ETH staking rejection
- ETH withdrawal
- Insufficient withdrawal rejection
- Reward calculation
- Reward claiming
- Preventing rewards from being claimed twice
- Multiple staking deposits
- Multiple-deposit reward accounting
- Partial-withdrawal reward accounting

### Test Result

```text
10 tests passed
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

The contract compiles successfully.

## Local Deployment

The contract was deployed locally using Foundry and Anvil.

Start Anvil:

```bash
anvil
```

Then deploy:

```bash
forge script script/DeploySimpleStaking.s.sol:DeploySimpleStaking \
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
SimpleStaking

Contract Address:
0x5FbDB2315678afecb367f032d93F642f64180aa3
```

## Contract Interaction with Cast

The deployed contract was interacted with using Foundry Cast.

### Stake 1 ETH

```bash
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
"stake()" \
--value 1ether \
--rpc-url http://127.0.0.1:8545 \
--private-key <ANVIL_PRIVATE_KEY>
```

### Check Staked Balance

```bash
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
"stakedBalance(address)(uint256)" \
<USER_ADDRESS> \
--rpc-url http://127.0.0.1:8545
```

### Check Total Staked

```bash
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
"totalStaked()(uint256)" \
--rpc-url http://127.0.0.1:8545
```

The deployed contract was successfully interacted with on the local Anvil blockchain.

## Project Structure

```text
06-SimpleStaking/
├── src/
│   └── SimpleStaking.sol
├── test/
│   └── SimpleStaking.t.sol
├── script/
│   └── DeploySimpleStaking.s.sol
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

This project was built to practice:

- Payable functions
- Receiving ETH
- Sending ETH from smart contracts
- `msg.value`
- `msg.sender`
- `block.timestamp`
- Solidity mappings
- Time-based calculations
- Reward accounting
- Internal helper functions
- Events
- Reverts and validation
- Foundry testing
- `vm.warp`
- Local EVM deployment
- Transaction broadcasting
- Contract interaction using Cast
- Reading and modifying on-chain state

## Disclaimer

This project is an educational implementation of a staking contract and is not intended for production use.

It has not been audited and should not be used to manage real funds.