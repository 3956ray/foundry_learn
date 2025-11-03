pragma solidity ^0.8.13;

contract Sss {
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

    function sentMes(Mes calldata mes) external {
        Mes memory m = mes;
        // 检查接收合约是否存在
        require(RECEIVE_ADDR != address(0), "receive addr not set");
        require(RECEIVE_ADDR.code.length > 0, "receive addr not contract");

        // 设置发送合约以及接收合约
        m.from = msg.sender;
        m.to = RECEIVE_ADDR;

        // 触发一个发送事件
        emit MessageSent(m.id, m.from, m.to);

        // 解耦的跨合约调用
        // 编码调用数据
        bytes4 selector = bytes4(keccak256("receiveMes((uint256,address,address))"));
        // m作为tuple传递
        bytes memory callData = abi.encodeWithSelector(selector, m);
        (bool ok, ) = RECEIVE_ADDR.call(callData);
        require(ok, "receiveMes failed");
    }
}