// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract DeploySimpleBank is Script {
    function run() external returns (SimpleBank) {
        vm.startBroadcast();
        SimpleBank bank = new SimpleBank();
        vm.stopBroadcast();
        return bank;
    }
}
