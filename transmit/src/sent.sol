// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IReceive {
    struct Mes {
        uint256 id;
        address from;
        address to;
    }

    function receiveMes(Mes calldata mes) external;
}

contract Sent {
    struct Mes{
        uint256 id;
        address from;
        address to;
    }
    // 接收的合约地址
    address public immutable RECEIVE_ADDR;

    // 这是一个事件，表示说发动了信息
    event MessageSent(uint256 indexed id, address indexed from, address indexed to);

    // 构造器
    constructor(address _receiveAddr) {
        RECEIVE_ADDR = _receiveAddr;

    }

    function sendMes( Mes calldata mes) external {
        Mes memory m = mes;
        m.from = msg.sender;
        m.to = RECEIVE_ADDR;

        emit MessageSent(m.id, m.from, m.to);

        IReceive(RECEIVE_ADDR).receiveMes(IReceive.Mes({id:m.id, from:m.from, to:m.to}));
    }
    
}
