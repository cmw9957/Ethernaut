// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {MagicNum} from "../src/MagicNumber.sol";

contract MagicNumberScript is Script {
    MagicNum public magicNumber;
    event LogCode(bytes code);

    address constant DEPLOYED_CONTRACT_ADDRESS = 0xEB5BdF8aB31449BB0eAbE6Cb656acdaeFCF629FC;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        magicNumber = MagicNum(DEPLOYED_CONTRACT_ADDRESS);
        bytes memory bytecode = hex"600a600c600039600a6000f3602a60505260206050f3";
        emit LogCode(bytecode);
        
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(deployedAddress != address(0), "Deployment failed");

        console.log("Deployed contract address:", deployedAddress);

        magicNumber.setSolver(deployedAddress);

        vm.stopBroadcast();
    }
}