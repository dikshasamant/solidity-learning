// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {ERC20Token} from "../src/ERC20Token.sol";

contract ERC20TokenTest is Test {

    ERC20Token token;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new ERC20Token(
            "Diksha Token",
            "DIK",
            18,
            1000
        );
    }

    function testTransfer() public {
        assertTrue(token.transfer(alice, 500));

        uint256 initialBalanceAlice = token.balanceOf(alice);
        uint256 initialBalanceBob = token.balanceOf(bob);

        vm.prank(alice);
        assertTrue(token.transfer(bob, 100));

        uint256 finalBalanceAlice = token.balanceOf(alice);
        uint256 finalBalanceBob = token.balanceOf(bob);

        assertEq(finalBalanceAlice, initialBalanceAlice - 100);
        assertEq(finalBalanceBob, initialBalanceBob + 100);
    }

    function testTransferInsufficientBalance() public {
        assertTrue(token.transfer(alice, 50));

        vm.prank(alice);
        vm.expectRevert("Insufficient balance");
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        token.transfer(bob, 100);
    }

    function testTransferEmitsEvent() public {
        assertTrue(token.transfer(alice, 200));

        vm.prank(alice);

        vm.expectEmit(true, true, false, true);
        emit ERC20Token.Transfer(alice, bob, 50);

        assertTrue(token.transfer(bob, 50));
    }

    function testApprove() public {
        assertTrue(token.transfer(alice, 500));

        vm.prank(alice);
        token.approve(bob, 200);

        assertEq(token.allowance(alice, bob), 200);
    }

    function testTransferFrom() public {
        assertTrue(token.transfer(alice, 500));

        vm.prank(alice);
        token.approve(bob, 200);

        vm.prank(bob);
        assertTrue(token.transferFrom(alice, bob, 150));

        assertEq(token.balanceOf(alice), 350);
        assertEq(token.balanceOf(bob), 150);
    }

    function testMint() public {
        uint256 initialTotalSupply = token.totalSupply();

        token.mint(alice, 500);

        assertEq(token.balanceOf(alice), 500);
        assertEq(token.totalSupply(), initialTotalSupply + 500);
    }

    function testMintOnlyOwner() public {
        vm.prank(alice);

        vm.expectRevert("Only owner can mint");
        token.mint(alice, 100);
    }

    function testBurn() public {
        assertTrue(token.transfer(alice, 200));

        vm.prank(alice);
        token.burn(100);

        assertEq(token.balanceOf(alice), 100);
        assertEq(token.totalSupply(), 900);
    }

    function testTransferFromAllowanceExceeded() public {
        assertTrue(token.transfer(alice, 500));

        vm.prank(alice);
        token.approve(bob, 200);

        vm.prank(bob);
        vm.expectRevert("Allowance exceeded");
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        token.transferFrom(alice, bob, 250);
    }

    function testBurnInsufficientBalance() public {
        assertTrue(token.transfer(alice, 50));

        vm.prank(alice);
        vm.expectRevert("Insufficient balance");
        token.burn(100);
    }

    function testMintEmitsEvent() public {
        uint256 initialTotalSupply = token.totalSupply();

        vm.expectEmit(true, true, false, true);
        emit ERC20Token.Transfer(address(0), alice, 100);

        token.mint(alice, 100);

        assertEq(token.balanceOf(alice), 100);
        assertEq(token.totalSupply(), initialTotalSupply + 100);
    }

    function testBurnEmitsEvent() public {
        assertTrue(token.transfer(alice, 200));

        vm.prank(alice);

        vm.expectEmit(true, true, false, true);
        emit ERC20Token.Transfer(alice, address(0), 100);

        token.burn(100);
    }
}