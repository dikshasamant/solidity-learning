// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract SimpleBankTest is Test {
    SimpleBank bank;

    function setUp() public {
        bank = new SimpleBank();
    }

    function testDeposit() public {
        address alice = makeAddr("alice");
        vm.deal(alice, 4 ether);
        vm.prank(alice);
        bank.deposit{value: 1 ether}();
        assertEq(bank.balanceOf(alice), 1 ether);
        vm.prank(alice);
        bank.deposit{value: 3 ether}();
        assertEq(bank.balanceOf(alice), 4 ether);
    }

    function testWithdraw() public {
        address alice = makeAddr("alice");
        vm.deal(alice, 4 ether);
        vm.prank(alice);
        bank.deposit{value: 4 ether}();
        assertEq(bank.balanceOf(alice), 4 ether);
        vm.prank(alice);
        bank.withdraw(2 ether);
        assertEq(bank.balanceOf(alice), 2 ether);
    }

    function testWithdrawInsufficientBalance() public {
        address alice = makeAddr("alice");
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        bank.deposit{value: 1 ether}();
        assertEq(bank.balanceOf(alice), 1 ether);
        vm.prank(alice);
        vm.expectRevert("Insufficient balance");
        bank.withdraw(2 ether);
    }

    function testMultipleUsers() public {
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");
        vm.deal(alice, 4 ether);
        vm.deal(bob, 2 ether);
        vm.prank(alice);
        bank.deposit{value: 4 ether}();
        vm.prank(bob);
        bank.deposit{value: 2 ether}();
        assertEq(bank.balanceOf(alice), 4 ether);
        assertEq(bank.balanceOf(bob), 2 ether);
    }   

    function testWithdrawAll() public {
        address alice = makeAddr("alice");
        vm.deal(alice, 4 ether);
        vm.prank(alice);
        bank.deposit{value: 4 ether}();
        assertEq(bank.balanceOf(alice), 4 ether);
        vm.prank(alice);
        bank.withdraw(4 ether);
        assertEq(bank.balanceOf(alice), 0);
    }
}