pragma solidity ^0.8.13;

import {Rec} from "./rec.sol";

contract Se {
    struct Mes {
        uint256 id;
        address from;
        address to;
    }

    // 这是一个事件，表示说发送了信息
    event MessageSent(uint256 indexed id, address indexed from, address indexed to);

    // 找到接收合约的地址
    address public immutable RECEIVE_ADDR;

    // 构造器
    constructor(address _receiveAddr) {
        RECEIVE_ADDR = _receiveAddr;
    }

    // 发送信息函数
    function sentMes( Mes calldata mes) external {
        Mes memory m = mes;
        // 检查接收合约是否存在
        require(RECEIVE_ADDR != address(0), "receive addr not set");

        // 设置发送合约以及接收合约
        m.from = msg.sender;
        m.to = RECEIVE_ADDR;

        // 触发一个发送事件
        emit MessageSent(m.id, m.from, m.to);
        Rec.Mes memory rMes = Rec.Mes({id: m.id, from: m.from, to: m.to});
        Rec(RECEIVE_ADDR).receiveMes(rMes);
    }
}