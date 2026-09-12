// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet wallet;

    address owner1 = makeAddr("owner1");
    address owner2 = makeAddr("owner2");
    address owner3 = makeAddr("owner3");
    address nonOwner = makeAddr("nonOwner");

    function setUp() public {
        address[] memory owners = new address[](3);

        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        wallet = new MultiSigWallet(owners, 2);
    }

    function testOwnersAreSetCorrectly() public view {
        assertTrue(wallet.isOwner(owner1));
        assertTrue(wallet.isOwner(owner2));
        assertTrue(wallet.isOwner(owner3));

        assertFalse(wallet.isOwner(nonOwner));

        assertEq(wallet.required(), 2);
    }

    function testSubmitTransaction() public {
        vm.prank(owner1);

        wallet.submitTransaction(owner2, 1 ether, "");

        assertEq(wallet.getTransactionCount(), 1);

        (address to, uint256 value, bytes memory data, bool executed, uint256 confirmations) = wallet.getTransaction(0);

        assertEq(to, owner2);
        assertEq(value, 1 ether);
        assertEq(data.length, 0);
        assertFalse(executed);
        assertEq(confirmations, 0);
    }

    function testNonOwnerCannotSubmit() public {
        vm.prank(nonOwner);

        vm.expectRevert("Not an owner");

        wallet.submitTransaction(owner2, 1 ether, "");
    }

    function testConfirmTransaction() public {
        vm.prank(owner1);
        wallet.submitTransaction(owner2, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        (,,,, uint256 confirmations) = wallet.getTransaction(0);

        assertEq(confirmations, 1);
    }

    function testTwoOwnersCanConfirm() public {
        vm.prank(owner1);
        wallet.submitTransaction(owner2, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        (,,,, uint256 confirmations) = wallet.getTransaction(0);

        assertEq(confirmations, 2);
    }

    function testOwnerCannotConfirmTwice() public {
        vm.prank(owner1);
        wallet.submitTransaction(owner2, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner1);

        vm.expectRevert("Already confirmed");

        wallet.confirmTransaction(0);
    }

    function testNonOwnerCannotConfirm() public {
        vm.prank(owner1);
        wallet.submitTransaction(owner2, 1 ether, "");

        vm.prank(nonOwner);

        vm.expectRevert("Not an owner");

        wallet.confirmTransaction(0);
    }

    function testOwnerCanRevokeConfirmation() public {
        vm.prank(owner1);
        wallet.submitTransaction(owner2, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner1);
        wallet.revokeConfirmation(0);

        (,,,, uint256 confirmations) = wallet.getTransaction(0);

        assertEq(confirmations, 0);
    }

    function testCannotRevokeWithoutConfirmation() public {
        vm.prank(owner1);
        wallet.submitTransaction(owner2, 1 ether, "");

        vm.prank(owner1);

        vm.expectRevert("Not confirmed");

        wallet.revokeConfirmation(0);
    }

    function testNonOwnerCannotRevoke() public {
        vm.prank(owner1);
        wallet.submitTransaction(owner2, 1 ether, "");

        vm.prank(nonOwner);

        vm.expectRevert("Not an owner");

        wallet.revokeConfirmation(0);
    }

    function testCannotExecuteWithoutEnoughConfirmations() public {
        vm.prank(owner1);
        wallet.submitTransaction(owner2, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner1);

        vm.expectRevert("Not enough confirmations");

        wallet.executeTransaction(0);
    }

    function testExecuteTransaction() public {
        vm.deal(address(wallet), 5 ether);

        uint256 recipientBalanceBefore = owner3.balance;

        vm.prank(owner1);
        wallet.submitTransaction(owner3, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        vm.prank(owner1);
        wallet.executeTransaction(0);

        assertEq(owner3.balance, recipientBalanceBefore + 1 ether);
        assertEq(address(wallet).balance, 4 ether);

        (,,, bool executed, uint256 confirmations) = wallet.getTransaction(0);

        assertTrue(executed);
        assertEq(confirmations, 2);
    }

    function testCannotExecuteTransactionTwice() public {
        vm.deal(address(wallet), 5 ether);

        vm.prank(owner1);
        wallet.submitTransaction(owner3, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        vm.prank(owner1);
        wallet.executeTransaction(0);

        vm.prank(owner1);

        vm.expectRevert("Already executed");

        wallet.executeTransaction(0);
    }

    function testCannotExecuteAfterRevokingConfirmation() public {
        vm.deal(address(wallet), 5 ether);

        vm.prank(owner1);
        wallet.submitTransaction(owner3, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.revokeConfirmation(0);

        vm.prank(owner1);

        vm.expectRevert("Not enough confirmations");

        wallet.executeTransaction(0);
    }

    function testCannotConfirmAfterExecution() public {
        vm.deal(address(wallet), 5 ether);

        vm.prank(owner1);
        wallet.submitTransaction(owner3, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        vm.prank(owner1);
        wallet.executeTransaction(0);

        vm.prank(owner3);

        vm.expectRevert("Already executed");

        wallet.confirmTransaction(0);
    }

    function test_RevertWhen_TransactionFails() public {
        vm.deal(address(wallet), 5 ether);

        RevertingReceiver receiver = new RevertingReceiver();

        vm.prank(owner1);
        wallet.submitTransaction(address(receiver), 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        vm.prank(owner1);

        vm.expectRevert("Transaction failed");

        wallet.executeTransaction(0);

        (,,, bool executed,) = wallet.getTransaction(0);

        assertFalse(executed);
    }

    function test_RevertWhen_NoOwners() public {
        address[] memory owners = new address[](0);

        vm.expectRevert("No owners");

        new MultiSigWallet(owners, 1);
    }

    function test_RevertWhen_RequiredIsZero() public {
        address[] memory owners = new address[](1);
        owners[0] = owner1;

        vm.expectRevert("Invalid requirement");

        new MultiSigWallet(owners, 0);
    }

    function test_RevertWhen_RequiredExceedsOwners() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner2;

        vm.expectRevert("Requirement exceeds owners");

        new MultiSigWallet(owners, 3);
    }

    function test_RevertWhen_OwnerIsZeroAddress() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = address(0);

        vm.expectRevert("Invalid owner");

        new MultiSigWallet(owners, 2);
    }

    function test_RevertWhen_DuplicateOwner() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner1;

        vm.expectRevert("Duplicate owner");

        new MultiSigWallet(owners, 2);
    }
}

contract RevertingReceiver {
    fallback() external payable {
        revert("Receiver reverted");
    }

    receive() external payable {
        revert("Receiver reverted");
    }
}
