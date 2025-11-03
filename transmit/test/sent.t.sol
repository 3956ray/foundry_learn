// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Sent} from "../src/sent.sol";
import {received} from "../src/received.sol";

contract sentTest is Test {
    Sent internal s;
    received internal r;

    function setUp() public {
        // 部署接收合约
        r = new received();
        // 部署发送合约，传入接收合约地址
        s = new Sent(address(r));
    }

    function test_sendMes_delivers_to_received() public {
        // 构造最小消息（from/to 会在 sendMes 内被覆盖）
        Sent.Mes memory mes = Sent.Mes({
            id: 1,
            from: address(0),
            to: address(0)
        });

        // 调用发送函数：应在同一交易内调用 received.receiveMes 并登记
        s.sendMes(mes);

        // 接收合约标记已收到（最小版 received 中的 receivedFlag[ID]）
        assertTrue(r.receivedFlag(1), "message not received");
    }
}
