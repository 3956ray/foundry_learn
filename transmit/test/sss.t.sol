pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Sss} from "../src/sss.sol";
import {Rec} from "../src/rec.sol";
contract SssTest is Test {
    Sss sss;
    Rec rec;
    function setUp() public {
        rec = new Rec();
        sss = new Sss(address(rec));
    }

    function testSentMes_Success() public {
        Sss.Mes memory m = Sss.Mes(1, address(0), address(0));
        sss.sentMes(m);
        assertTrue(rec.received(1), "message not received");
    }

    function testSentMes_Revert_ZeroAddr() public {
        Sss sssZero = new Sss(address(0));
        Sss.Mes memory m = Sss.Mes(2, address(0), address(0));
        vm.expectRevert(bytes("receive addr not set"));
        sssZero.sentMes(m);
    }

    function testSentMes_Revert_EOA() public {
        address eoa = address(0xBEEF);
        Sss sssEoa = new Sss(eoa);
        Sss.Mes memory m = Sss.Mes(3, address(0), address(0));
        vm.expectRevert(bytes("receive addr not contract"));
        sssEoa.sentMes(m);
    }
}