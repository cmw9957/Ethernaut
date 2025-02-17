// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Denial, Attack} from "../src/Denial.sol";

contract DenialScript is Script {
    address DEPLOYED_CONTRACT_ADDRESS = 0xEdf91834F1d2C4059Bd1dA30e08F6F371BA92F70;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        Attack attacker = new Attack(DEPLOYED_CONTRACT_ADDRESS);

        vm.stopBroadcast();
    }
}