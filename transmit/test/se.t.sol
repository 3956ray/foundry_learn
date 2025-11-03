pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Se} from "../src/se.sol";
import {Rec} from "../src/rec.sol";
contract SeTest is Test {
    Se se;
    Rec rec;
    address seAddr;
    address recAddr;
    function setUp() public {
        rec = new Rec();
        recAddr = address(rec);
        se = new Se(recAddr);
        seAddr = address(se);
    }

    function testSentMes() public {
        Se.Mes memory m = Se.Mes(1, address(0), address(0));
        se.sentMes(m);
        assertTrue(rec.received(1), "message not received");
    }

}