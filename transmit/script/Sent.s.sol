// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import {Script, console} from "forge-std/Script.sol";
import {Sent} from "../src/sent.sol";
import {received} from "../src/received.sol";
 
contract sentScript is Script {
    Sent internal s;
    received internal r;
 
    function setUp() public {}
 
    function run() public {
        vm.startBroadcast();

         // 1) 部署接收合约
        r = new received();
        console.log("received deployed at:", address(r));

        // 2) 部署发送合约（传入接收合约地址）
        s = new Sent(address(r));
        console.log("Sent deployed at:", address(s));

        // 3) 构造最小消息（from/to 会在 sendMes 内被覆盖）
        Sent.Mes memory mes = Sent.Mes({
            id: 1,
            from: address(0),
            to: address(0)
        });

        // 4) 发送消息（同一笔交易内会调用 received.receiveMes）
        s.sendMes(mes);
        console.log("Message(ID=1) sent to received.");
 
        vm.stopBroadcast();
    }
}