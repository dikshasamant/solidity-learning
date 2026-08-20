// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {SimpleStaking} from "../src/SimpleStaking.sol";

contract SimpleStakingTest is Test {

    SimpleStaking staking;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        staking = new SimpleStaking();

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function testStake() public {
        vm.prank(alice);

        staking.stake{value: 1 ether}();

        assertEq(staking.stakedBalance(alice), 1 ether);
        assertEq(staking.totalStaked(), 1 ether);
    }

    function testWithdraw() public {
        vm.prank(alice);
        staking.stake{value: 1 ether}();

        uint256 initialBalance = alice.balance;

        vm.prank(alice);
        staking.withdraw(0.5 ether);

        assertEq(staking.stakedBalance(alice), 0.5 ether);
        assertEq(staking.totalStaked(), 0.5 ether);
        assertEq(alice.balance, initialBalance + 0.5 ether);
    }

    function testWithdrawInsufficientBalance() public {
        vm.prank(alice);
        staking.stake{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert("Insufficient staked balance");
        staking.withdraw(2 ether);
    }

    function testStakeZeroETH() public {
        vm.prank(alice);
        vm.expectRevert("Must stake ETH");
        staking.stake{value: 0}();
    }

    function testCalculateReward() public {
        vm.prank(alice);
        staking.stake{value: 1 ether}();

        vm.warp(block.timestamp + 365 days);

        uint256 reward = staking.calculateReward(alice);

        assertEq(reward, 0.1 ether);
    }

    function testClaimReward() public {
        vm.prank(alice);
        staking.stake{value: 2 ether}();

        vm.warp(block.timestamp + 365 days);

        vm.deal(address(staking), 2.2 ether);

        uint256 initialBalance = alice.balance;

        vm.prank(alice);
        staking.claimReward();

        assertEq(alice.balance, initialBalance + 0.2 ether);
    }

    function testCannotClaimRewardTwice() public {
        vm.prank(alice);
        staking.stake{value: 2 ether}();

        vm.warp(block.timestamp + 365 days);

        vm.deal(address(staking), 2.4 ether);

        vm.prank(alice);
        staking.claimReward();

        vm.prank(alice);
        vm.expectRevert("No rewards available");
        staking.claimReward();
    }

    function testMultipleStakes() public {
        vm.prank(alice);
        staking.stake{value: 1 ether}();

        vm.warp(block.timestamp + 100 days);

        vm.prank(alice);
        staking.stake{value: 1 ether}();

        assertEq(staking.stakedBalance(alice), 2 ether);
    }

    function testMultipleStakesRewardAccounting() public {
        vm.prank(alice);
        staking.stake{value: 1 ether}();

        vm.warp(block.timestamp + 100 days);

        vm.prank(alice);
        staking.stake{value: 1 ether}();

        vm.warp(block.timestamp + 100 days);

        uint256 reward = staking.calculateReward(alice);

        uint256 firstStake = 1 ether;
        uint256 secondStake = 1 ether;

        uint256 firstStakeReward =
            firstStake * 10 * 200 days / 100 / 365 days;

        uint256 secondStakeReward =
            secondStake * 10 * 100 days / 100 / 365 days;

        assertEq(reward, firstStakeReward + secondStakeReward);
    }

    function testPartialWithdrawRewardAccounting() public {
        vm.prank(alice);
        staking.stake{value: 2 ether}();

        vm.warp(block.timestamp + 100 days);

        vm.prank(alice);
        staking.withdraw(1 ether);

        vm.warp(block.timestamp + 100 days);

        uint256 reward = staking.calculateReward(alice);

        uint256 firstPeriodStake = 2 ether;
        uint256 secondPeriodStake = 1 ether;

        uint256 firstPeriodReward =
            firstPeriodStake * 10 * 100 days / 100 / 365 days;

        uint256 secondPeriodReward =
            secondPeriodStake * 10 * 100 days / 100 / 365 days;

        assertEq(reward, firstPeriodReward + secondPeriodReward);
    }

    function testClaimRewardInsufficientContractBalance() public {
        vm.prank(alice);
        staking.stake{value: 1 ether}();

        vm.warp(block.timestamp + 365 days);

        vm.prank(alice);
        staking.withdraw(1 ether);

        vm.prank(alice);
        vm.expectRevert("Insufficient contract balance");
        staking.claimReward();
    }

    function testStakeEmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit SimpleStaking.Staked(alice, 1 ether);

        vm.prank(alice);
        staking.stake{value: 1 ether}();
    }

    function testWithdrawEmitsEvent() public {
        vm.prank(alice);
        staking.stake{value: 1 ether}();

        vm.expectEmit(true, false, false, true);
        emit SimpleStaking.Withdrawn(alice, 0.5 ether);

        vm.prank(alice);
        staking.withdraw(0.5 ether);
    }

    function testClaimRewardEmitsEvent() public {
        vm.prank(alice);
        staking.stake{value: 1 ether}();

        vm.warp(block.timestamp + 365 days);

        vm.expectEmit(true, false, false, true);
        emit SimpleStaking.RewardClaimed(alice, 0.1 ether);

        vm.prank(alice);
        staking.claimReward();
    }

}