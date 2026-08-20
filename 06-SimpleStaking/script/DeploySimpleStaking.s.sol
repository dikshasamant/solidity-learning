// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SimpleStaking} from "../src/SimpleStaking.sol";

contract DeploySimpleStaking is Script {
    function run() external returns (SimpleStaking) {
        vm.startBroadcast();

        SimpleStaking staking = new SimpleStaking();

        vm.stopBroadcast();

        return staking;
    }
}