// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowTest is Test {

    Escrow escrow;

    address client = makeAddr("client");
    address freelancer = makeAddr("freelancer");

    function setUp() public {
        escrow = new Escrow();
    }

    function testCreateEscrow() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        (address storedClient, address storedFreelancer, uint256 storedAmount, uint256 storedDeadline, Escrow.State storedState) = escrow.escrows(1);

        assertEq(storedClient, client);
        assertEq(storedFreelancer, freelancer);
        assertEq(storedAmount, amount);
        assertEq(storedDeadline, deadline);
        assertEq(uint256(storedState), uint256(Escrow.State.CREATED));
    }

    function testCreateEscrowWithInvalidFreelancer() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        vm.expectRevert("Invalid freelancer address");
        escrow.createEscrow(address(0), amount, deadline);
    }

    function testCreateEscrowWithZeroAmount() public {
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        vm.expectRevert("Amount must be greater than zero");
        escrow.createEscrow(freelancer, 0, deadline);
    }

    function testCreateEscrowWithPastDeadline() public {
        uint256 amount = 1 ether;
        vm.warp(10 days);
        uint256 deadline = block.timestamp - 1 days;

        vm.prank(client);
        vm.expectRevert("Deadline must be in the future");
        escrow.createEscrow(freelancer, amount, deadline);
    }

    function testFundEscrow() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        (, , , , Escrow.State state) = escrow.escrows(1);

        assertEq(uint256(state), uint256(Escrow.State.FUNDED));
        assertEq(address(escrow).balance, amount);
    }

    function testStartWork() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(freelancer);
        escrow.startWork(1);

        (, , , , Escrow.State state) = escrow.escrows(1);

        assertEq(uint256(state), uint256(Escrow.State.IN_PROGRESS));
    }

    function testSubmitWork() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(freelancer);
        escrow.startWork(1);

        vm.prank(freelancer);
        escrow.submitWork(1);

        (, , , , Escrow.State state) = escrow.escrows(1);

        assertEq(uint256(state), uint256(Escrow.State.COMPLETED));
    }

    function testApproveWork() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(freelancer);
        escrow.startWork(1);

        vm.prank(freelancer);
        escrow.submitWork(1);

        uint256 freelancerBalanceBefore = freelancer.balance;

        vm.prank(client);
        escrow.approveWork(1);

        (, , , , Escrow.State state) = escrow.escrows(1);

        assertEq(uint256(state), uint256(Escrow.State.RELEASED));
        assertEq(freelancer.balance, freelancerBalanceBefore + amount);
    }

    function testRefundEscrow() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.warp(deadline + 1 days);

        uint256 clientBalanceBefore = client.balance;

        vm.prank(client);
        escrow.refundEscrow(1);

        (, , , , Escrow.State state) = escrow.escrows(1);

        assertEq(uint256(state), uint256(Escrow.State.REFUNDED));
        assertEq(client.balance, clientBalanceBefore + amount);
    }

    function testFundEscrowWithNonClient() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(freelancer, amount);

        vm.prank(freelancer);
        vm.expectRevert("Only the client can fund the escrow");
        escrow.fundEscrow{value: amount}(1);
    }

    function testFundEscrowWithWrongAmount() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, 2 ether);

        vm.prank(client);
        vm.expectRevert("Incorrect funding amount");
        escrow.fundEscrow{value: 2 ether}(1);
    } 

    function testStartWorkWithNonFreelancer() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(client);
        vm.expectRevert("Only the freelancer can start work");
        escrow.startWork(1);
    }

    function testStartWorkBeforeFunding() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.prank(freelancer);
        vm.expectRevert("Escrow is not in FUNDED state");
        escrow.startWork(1);
    }  

    function testSubmitWorkWithNonFreelancer() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(freelancer);
        escrow.startWork(1);

        vm.prank(client);
        vm.expectRevert("Only the freelancer can submit work");
        escrow.submitWork(1);
    }

    function testSubmitWorkBeforeWorkStarted() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(freelancer);
        vm.expectRevert("Escrow is not in IN_PROGRESS state");
        escrow.submitWork(1);
    }  

    function testApproveWorkWithNonClient() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(freelancer);
        escrow.startWork(1);

        vm.prank(freelancer);
        escrow.submitWork(1);

        vm.prank(freelancer);
        vm.expectRevert("Only the client can approve work");
        escrow.approveWork(1);
    } 

    function testApproveWorkBeforeCompletion() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(client);
        vm.expectRevert("Escrow is not in COMPLETED state");
        escrow.approveWork(1);
    }

    function testRefundEscrowBeforeDeadline() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(client);
        vm.expectRevert("Cannot refund before the deadline");
        escrow.refundEscrow(1);
    }

    function testRefundEscrowWithNonClient() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.warp(deadline + 1);

        vm.prank(freelancer);
        vm.expectRevert("Only the client can refund the escrow");
        escrow.refundEscrow(1);
    }

    function testRefundEscrowAfterRelease() public {
        uint256 amount = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(client);
        escrow.createEscrow(freelancer, amount, deadline);

        vm.deal(client, amount);

        vm.prank(client);
        escrow.fundEscrow{value: amount}(1);

        vm.prank(freelancer);
        escrow.startWork(1);

        vm.prank(freelancer);
        escrow.submitWork(1);

        vm.prank(client);
        escrow.approveWork(1);

        vm.warp(deadline + 1);

        vm.prank(client);
        vm.expectRevert("Escrow is not in FUNDED or IN_PROGRESS state");
        escrow.refundEscrow(1);
    }

}