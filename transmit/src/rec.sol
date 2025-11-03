pragma solidity ^0.8.13;

 contract Rec {
    struct Mes {
        uint256 id;
        address from;
        address to;
    }

    // 有一个接收状态
    mapping(uint256 => bool) public received;

    // 这是一个事件，表示说收到了信息
    event MessageReceived(uint256 indexed id, address indexed from, address indexed to);

    // 接收信息函数
    function receiveMes(Mes calldata mes) external {
        // 触发一个接收事件
        require(!received[mes.id], "already received");
        received[mes.id] = true;
        emit MessageReceived(mes.id, mes.from, mes.to);
    }
 }