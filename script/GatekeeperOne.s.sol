// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {GatekeeperOne} from "../src/GatekeeperOne.sol";

contract GatekeeperOneScript is Script {
    GatekeeperOne public gateKeeperOne;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        gateKeeperOne = new GatekeeperOne();

        vm.stopBroadcast();
    }
}