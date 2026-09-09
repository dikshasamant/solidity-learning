// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {
    
    enum State {
        CREATED,
        FUNDED,
        IN_PROGRESS,
        COMPLETED,
        RELEASED,
        REFUNDED
    }

    struct EscrowAgreement {
        address client;
        address freelancer;
        uint256 amount;
        uint256 deadline;
        State state;
    } 

    mapping(uint256 => EscrowAgreement) public escrows;

    uint256 public escrowCount;  

    event EscrowCreated(
        uint256 indexed escrowId,
        address indexed client,
        address indexed freelancer,
        uint256 amount,
        uint256 deadline
    );

    function createEscrow(address _freelancer, uint256 _amount, uint256 _deadline) external {
        require(_freelancer != address(0), "Invalid freelancer address");
        require(_amount > 0, "Amount must be greater than zero");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        escrowCount++;
        escrows[escrowCount] = EscrowAgreement({
            client: msg.sender,
            freelancer: _freelancer,
            amount: _amount,
            deadline: _deadline,
            state: State.CREATED
        });

        emit EscrowCreated(escrowCount, msg.sender, _freelancer, _amount, _deadline);
    }

    function fundEscrow(uint256 _escrowId) external payable {
        EscrowAgreement storage escrow = escrows[_escrowId];
        require(escrow.state == State.CREATED, "Escrow is not in CREATED state");
        require(msg.sender == escrow.client, "Only the client can fund the escrow");
        require(msg.value == escrow.amount, "Incorrect funding amount");
    
        escrow.state = State.FUNDED;
    }

    function startWork(uint256 _escrowId) external {
        EscrowAgreement storage escrow = escrows[_escrowId];
        require(escrow.state == State.FUNDED, "Escrow is not in FUNDED state");
        require(msg.sender == escrow.freelancer, "Only the freelancer can start work");
    
        escrow.state = State.IN_PROGRESS;
    }

    function submitWork(uint256 _escrowId) external {
        EscrowAgreement storage escrow = escrows[_escrowId];
        require(escrow.state == State.IN_PROGRESS, "Escrow is not in IN_PROGRESS state");
        require(msg.sender == escrow.freelancer, "Only the freelancer can submit work");
    
        escrow.state = State.COMPLETED;
    }

    function approveWork(uint256 _escrowId) external {
        EscrowAgreement storage escrow = escrows[_escrowId];
        require(escrow.state == State.COMPLETED, "Escrow is not in COMPLETED state");
        require(msg.sender == escrow.client, "Only the client can approve work");
    
        escrow.state = State.RELEASED;
        (bool success, ) = escrow.freelancer.call{value: escrow.amount}("");
        require(success, "ETH transfer failed");
    }

    function refundEscrow(uint256 _escrowId) external {
        EscrowAgreement storage escrow = escrows[_escrowId];
        require(escrow.state == State.FUNDED || escrow.state == State.IN_PROGRESS, "Escrow is not in FUNDED or IN_PROGRESS state");
        require(block.timestamp > escrow.deadline, "Cannot refund before the deadline");
        require(msg.sender == escrow.client, "Only the client can refund the escrow");
        escrow.state = State.REFUNDED;
        (bool success, ) = escrow.client.call{value: escrow.amount}("");
        require(success, "ETH transfer failed");
    }
}