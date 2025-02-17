// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {GatekeeperTwo, Attack} from "../src/GatekeeperTwo.sol";

contract GatekeeperOneScript is Script {
    GatekeeperOne public gateKeeperOne;

    address constant DEPLOYED_CONTRACT_ADDRESS = 0x7a1a98642d342ACa619AC93caD9dDa2C9c78F431;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        
        gateKeeperOne = new GatekeeperOne();
        
        Attack attacker = new Attack(gateKeeperOne);

        attacker.attack();

        vm.stopBroadcast();
    }
}