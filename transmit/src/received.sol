// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract received {
    struct Mes {
        uint256 id;
        address from;
        address to;
    }

    mapping(uint256 => bool) public receivedFlag;

    event MessageReceived(uint256 indexed id, address indexed from, address indexed to);

    function receiveMes(Mes calldata mes) external {
        receivedFlag[mes.id] = true;
        emit MessageReceived(mes.id, mes.from, mes.to);
    }
}
