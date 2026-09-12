// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract DeployMultiSigWallet is Script {
    function run() external returns (MultiSigWallet) {
        address[] memory owners = new address[](3);

        owners[0] = vm.envAddress("OWNER1");
        owners[1] = vm.envAddress("OWNER2");
        owners[2] = vm.envAddress("OWNER3");

        vm.startBroadcast();

        MultiSigWallet wallet = new MultiSigWallet(owners, 2);

        vm.stopBroadcast();

        return wallet;
    }
}
