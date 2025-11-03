pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Sss} from "../src/sss.sol";
import {Rec} from "../src/rec.sol";
contract SssScript is Script {
    Sss internal sss;
    Rec internal rec;
    function setUp() public {
        
       
    }

    function run() public {
        vm.startBroadcast();

        // 部署合约
        rec = new Rec();
        sss = new Sss(address(rec));
        console.log("Rec deployed at:", address(rec));
        console.log("sss deployed at:", address(sss));
        Sss.Mes memory m = Sss.Mes(1, address(0), address(0));
        sss.sentMes(m);
        // assertTrue(rec.received(1), "message not received");
        vm.stopBroadcast();
    }
}