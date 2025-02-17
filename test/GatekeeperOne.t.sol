// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol"; // forge-std 라이브러리의 Test를 import
import {GatekeeperOne, Attack}  from "../src/GatekeeperOne.sol"; // GatekeeperOne 계약을 import

contract GatekeeperOneTest is Test {
    GatekeeperOne public gatekeeperOne;
    Attack public attack;

    // 테스트를 위한 setup
    function setUp() public {
        gatekeeperOne = new GatekeeperOne();
        bytes8 gateKey = bytes8(uint64(uint160(address(this))));
        attack = new Attack(gatekeeperOne, gateKey);
    }

    // 공격 테스트 및 가스 소모량 추적
    function testAttack() public {
        uint256 initialGas = gasleft(); // 공격 전 남은 가스 확인

        // 공격 실행
        vm.startPrank(address(this)); // 이 주소를 사용하는 프랭크 시작
        attack.attack(); // 공격 실행
        vm.stopPrank(); // 프랭크 종료

        uint256 gasUsed = initialGas - gasleft(); // 사용된 가스 계산
        console.log("Attack used gas:", gasUsed); // 사용된 가스 출력
    }
}
