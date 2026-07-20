// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract VotingSystem {
    
    struct Candidate{
        uint id;
        string name;
        uint voteCount;
    }
    
    Candidate[] candidates;

    mapping(uint256 => Candidate) idToCandidate;
    mapping(address => bool) hasVoted;

    uint256 nextCandidateId = 1;

    function addCandidate(string memory _name) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        Candidate memory newCandidate = Candidate(nextCandidateId, _name, 0);
        candidates.push(newCandidate);
        idToCandidate[nextCandidateId] = newCandidate;
        nextCandidateId++;
    }

    function vote(uint256 _candidateId) public {
        require(_candidateId >= 1 && _candidateId < nextCandidateId, "Invalid candidate ID");
        require(!hasVoted[msg.sender], "You have already voted");

        idToCandidate[_candidateId].voteCount++;

        for (uint256 i = 0; i < candidates.length; i++) 
        {
            if (candidates[i].id == _candidateId) 
            {
                candidates[i].voteCount++;
                break;
            }
        }

        hasVoted[msg.sender] = true;
    }

    function getCandidate(uint256 _candidateId) public view returns (uint256, string memory, uint256) {
        require(_candidateId >= 1 && _candidateId < nextCandidateId, "Invalid candidate ID");
        Candidate memory candidate = idToCandidate[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }

    function getAllCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }

    function candidateCount() public view returns (uint256) {
        return candidates.length;
    }

    function updateCandidateName(uint256 _candidateId, string memory _newName) public {
        require(_candidateId >= 1 && _candidateId < nextCandidateId, "Invalid candidate ID");
        require(bytes(_newName).length > 0, "Name cannot be empty");
        idToCandidate[_candidateId].name = _newName;
        for (uint256 i = 0; i < candidates.length; i++) 
        {
            if (candidates[i].id == _candidateId) 
            {
                candidates[i].name = _newName;
                break;
            }
        }
    }

    function deleteCandidate(uint256 _candidateId) public {
        require(_candidateId >= 1 && _candidateId < nextCandidateId, "Invalid candidate ID");
        delete idToCandidate[_candidateId];
        for (uint256 i = 0; i < candidates.length; i++) 
        {
            if(candidates[i].id == _candidateId)
            {
                for (uint256 j = i; j < candidates.length - 1; j++) {
                    candidates[j] = candidates[j + 1];
                }
                candidates.pop();
                break;
            }
        }
    }
}

