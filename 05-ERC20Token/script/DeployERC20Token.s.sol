// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {ERC20Token} from "../src/ERC20Token.sol";

contract DeployERC20Token is Script {

    function run() external returns (ERC20Token) {
        vm.startBroadcast();

        ERC20Token token = new ERC20Token(
            "Diksha Token",
            "DIK",
            18,
            1000
        );

        vm.stopBroadcast();

        return token;
    }
}