# Voting System Smart Contract

A simple blockchain-based Voting System built in Solidity. This project demonstrates the use of structs, arrays, mappings, CRUD operations, and vote validation using `msg.sender` to ensure that each wallet address can vote only once.

---

## Features

- Add new candidates
- Vote for a candidate
- One wallet address can vote only once
- Retrieve a specific candidate
- Retrieve all candidates
- Get total number of candidates
- Update candidate names
- Delete candidates

---

## Smart Contract Information

- Language: Solidity
- Solidity Version: ^0.8.18
- License: MIT

---

## Data Structures

### Candidate Struct

```solidity
struct Candidate {
    uint id;
    string name;
    uint voteCount;
}
```

Each candidate stores:

- Unique ID
- Candidate Name
- Total Votes

---

## State Variables

### Candidate Array

```solidity
Candidate[] candidates;
```

Stores all candidates.

---

### Candidate Mapping

```solidity
mapping(uint256 => Candidate) idToCandidate;
```

Allows direct lookup of a candidate using its ID.

---

### Vote Tracking Mapping

```solidity
mapping(address => bool) hasVoted;
```

Tracks whether a wallet address has already voted.

---

### Candidate ID Counter

```solidity
uint256 nextCandidateId = 1;
```

Automatically generates unique IDs.

---

# Functions

## addCandidate()

Adds a new candidate.

### Parameters

- `string _name`

### Validation

- Candidate name cannot be empty.

---

## vote()

Allows a wallet to vote for a candidate.

### Parameters

- `uint256 _candidateId`

### Validation

- Candidate must exist.
- Wallet address can vote only once.

---

## getCandidate()

Returns information about a single candidate.

### Returns

- Candidate ID
- Candidate Name
- Vote Count

---

## getAllCandidates()

Returns all candidates.

---

## candidateCount()

Returns the total number of candidates.

---

## updateCandidateName()

Updates the name of an existing candidate.

### Validation

- Candidate must exist.
- Name cannot be empty.

---

## deleteCandidate()

Deletes a candidate from the system.

### Process

- Deletes candidate from mapping
- Removes candidate from array
- Shifts remaining elements
- Reduces array size using `pop()`

---

# Voting Logic

Every Ethereum wallet has its own unique address.

When a user votes, the contract stores:

```solidity
hasVoted[msg.sender] = true;
```

If the same wallet attempts to vote again, the transaction is reverted.

This ensures:

- One wallet = One vote

---

# Concepts Used

- Structs
- Arrays
- Mappings
- CRUD Operations
- Loops
- Functions
- Memory Variables
- Require Statements
- msg.sender
- Address Mapping
- Array Manipulation
- Data Validation

---

# Project Structure

```
VotingSystem.sol
README.md
```

---

# Future Improvements

- Owner-only candidate management
- Election start/end time
- Event logging
- Candidate search
- Winner declaration
- Gas optimization using Swap-and-Pop deletion
- Frontend integration using React
- Deployment on Ethereum Sepolia

---

# Author

**Diksha Samant**

Blockchain Developer | Solidity Learner | Web3 Enthusiast