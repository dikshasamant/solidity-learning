// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Crowdfunding} from "../src/Crowdfunding.sol";

contract CrowdfundingTest is Test {
    Crowdfunding crowdfunding;

    address alice = makeAddr("alice");

    function setUp() public {
        crowdfunding = new Crowdfunding();
        vm.deal(alice, 10 ether);
    }

    function testCreateCampaign() public {
        crowdfunding.createCampaign(1 ether, 1 weeks);

        (
            address creator,
            uint256 goal,
            uint256 pledged,
            uint256 deadline,
            bool exists,
            bool withdrawn
        ) = crowdfunding.campaigns(1);

        assertEq(creator, address(this));
        assertEq(goal, 1 ether);
        assertEq(pledged, 0);
        assertGt(deadline, block.timestamp);
        assertTrue(exists);
        assertFalse(withdrawn);
    }

    function testContribute() public {
        crowdfunding.createCampaign(1 ether, 1 weeks);

        vm.prank(alice);
        crowdfunding.contribute{value: 0.5 ether}(1);

        (
            ,
            ,
            uint256 pledged,
            ,
            ,
            
        ) = crowdfunding.campaigns(1);

        assertEq(pledged, 0.5 ether);
        assertEq(
            crowdfunding.contributions(1, alice),
            0.5 ether
        );
    }

    function testWithdrawFunds() public {
        crowdfunding.createCampaign(1 ether, 1 weeks);

        vm.prank(alice);
        crowdfunding.contribute{value: 1 ether}(1);

        assertEq(address(crowdfunding).balance, 1 ether);

        vm.warp(block.timestamp + 1 weeks);

        crowdfunding.withdrawFunds(1);

        assertEq(address(crowdfunding).balance, 0);

        (
            ,
            ,
            uint256 pledged,
            ,
            ,
            bool withdrawn
        ) = crowdfunding.campaigns(1);

        assertEq(pledged, 1 ether);
        assertTrue(withdrawn);
    }

    function testRefund() public {
        crowdfunding.createCampaign(2 ether, 1 weeks);

        vm.prank(alice);
        crowdfunding.contribute{value: 1 ether}(1);

        vm.warp(block.timestamp + 1 weeks);

        uint256 aliceBalanceBefore = alice.balance;

        vm.prank(alice);
        crowdfunding.refund(1);

        uint256 aliceBalanceAfter = alice.balance;

        assertEq(aliceBalanceAfter - aliceBalanceBefore, 1 ether);
        assertEq(crowdfunding.contributions(1, alice), 0);

        (
            ,
            ,
            uint256 pledged,
            ,
            ,
            
        ) = crowdfunding.campaigns(1);

        assertEq(pledged, 0);
    }

    function testCannotContributeAfterDeadline() public {
        crowdfunding.createCampaign(1 ether, 1 weeks);

        vm.warp(block.timestamp + 1 weeks);

        vm.expectRevert("Campaign has ended");
        crowdfunding.contribute{value: 1 ether}(1);
    }

    function testCannotWithdrawIfGoalNotReached() public {
        crowdfunding.createCampaign(2 ether, 1 weeks);

        vm.prank(alice);
        crowdfunding.contribute{value: 1 ether}(1);

        vm.warp(block.timestamp + 1 weeks);

        vm.expectRevert("Goal not reached");
        crowdfunding.withdrawFunds(1);
    }

    function testCannotRefundIfGoalReached() public {
        crowdfunding.createCampaign(1 ether, 1 weeks);

        vm.prank(alice);
        crowdfunding.contribute{value: 1 ether}(1);

        vm.warp(block.timestamp + 1 weeks);

        vm.expectRevert("Goal was reached");

        vm.prank(alice);
        crowdfunding.refund(1);
    }

    receive() external payable {}
}