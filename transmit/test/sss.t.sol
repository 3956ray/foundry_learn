pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Sss} from "../src/sss.sol";
import {Rec} from "../src/rec.sol";
contract SssTest is Test {
    Sss sss;
    Rec rec;
    // 为 expectEmit 声明事件签名（与合约事件一致）
    event MessageSent(uint256 indexed id, address indexed from, address indexed to);
    event MessageReceived(uint256 indexed id, address indexed from, address indexed to);
    function setUp() public {
        rec = new Rec();
        sss = new Sss(address(rec));
    }

    function testSentMes_Success() public {
        Sss.Mes memory m = Sss.Mes(1, address(0), address(0));
        // 发送端事件
        vm.expectEmit(true, true, true, true, address(sss));
        emit MessageSent(1, address(this), address(rec));
        // 接收端事件
        vm.expectEmit(true, true, true, true, address(rec));
        emit MessageReceived(1, address(this), address(rec));

        sss.sentMes(m);
        assertTrue(rec.received(1), "message not received");
        m = Sss.Mes(2, address(0), address(0));

        // 多次发送
        vm.expectEmit(true, true, true, true, address(sss));
        emit MessageSent(2, address(this), address(rec));
        vm.expectEmit(true, true, true, true, address(rec));
        emit MessageReceived(2, address(this), address(rec));

        sss.sentMes(m);
        assertTrue(rec.received(2), "message not received");
    }

    function testSentMes_string() public {
        // 临时地址
        address alice = vm.addr(0x1337);
        address bob = vm.addr(0x1338);

        // alice 发送 id=3
        Sss.Mes memory m = Sss.Mes(3, address(0), address(0));
        // 发送端事件（from=alice）
        vm.expectEmit(true, true, true, true, address(sss));
        emit MessageSent(3, alice, address(rec));
        // 接收端事件（from=alice）
        vm.expectEmit(true, true, true, true, address(rec));
        emit MessageReceived(3, alice, address(rec));

        vm.prank(alice);
        sss.sentMes(m);
        vm.stopPrank();
        assertTrue(rec.received(3), "message not received");

        // bob 连续发送 id=4（演示 startPrank/endPrank）
        Sss.Mes memory m2 = Sss.Mes(4, address(0), address(0));
        vm.expectEmit(true, true, true, true, address(sss));
        emit MessageSent(4, bob, address(rec));
        vm.expectEmit(true, true, true, true, address(rec));
        emit MessageReceived(4, bob, address(rec));
        vm.startPrank(bob);
        sss.sentMes(m2);
        vm.stopPrank();
        assertTrue(rec.received(4), "message not received");
    }
    
    function testSentMes_Revert_Duplicate() public {
        Sss.Mes memory m = Sss.Mes(99, address(0), address(0));
        sss.sentMes(m);
        // 第二次发送同一 id，应因接收端 already received 而失败，外层统一错误文案
        vm.expectRevert(bytes("receiveMes failed"));
        sss.sentMes(m);
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

    
    function testSentMes_ExpectCallEncoding() public {
        // 构造消息
        Sss.Mes memory m = Sss.Mes(123, address(0), address(0));
        // 期望对 rec calldata 与 selector+tuple 编码完全一致
        bytes4 selector = bytes4(keccak256("receiveMes((uint256,address,address))"));
        bytes memory expected = abi.encodeWithSelector(selector, Sss.Mes({id: 123, from: address(this), to: address(rec)}));
        vm.expectCall(address(rec), expected);

        sss.sentMes(m);
        assertTrue(rec.received(123), "message not received");
    }

    function testSentMes_BoundaryIds() public {
        // id=0 边界
        Sss.Mes memory m0 = Sss.Mes(0, address(0), address(0));
        vm.expectEmit(true, true, true, true, address(sss));
        emit MessageSent(0, address(this), address(rec));
        vm.expectEmit(true, true, true, true, address(rec));
        emit MessageReceived(0, address(this), address(rec));
        sss.sentMes(m0);
        assertTrue(rec.received(0), "message id=0 not received");

        // id=最大值
        uint256 maxId = type(uint256).max;
        Sss.Mes memory mm = Sss.Mes(maxId, address(0), address(0));
        vm.expectEmit(true, true, true, true, address(sss));
        emit MessageSent(maxId, address(this), address(rec));
        vm.expectEmit(true, true, true, true, address(rec));
        emit MessageReceived(maxId, address(this), address(rec));
        sss.sentMes(mm);
        assertTrue(rec.received(maxId), "message max id not received");
    }
}