// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { OApp, Origin, MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { IOAppComposer } from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppComposer.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract AckComposerOApp is OApp, IOAppComposer {
    address public baseOApp;  // 只信任来自哪个 Base OApp 的 composed 消息
    using OptionsBuilder for bytes;


    constructor(address _endpoint, address _owner, address _baseOApp)
        OApp(_endpoint, _owner)
        Ownable(_owner)
    {
        baseOApp = _baseOApp;
    }

    // 作为 OApp，用不到接收逻辑，这里留空
    function _lzReceive(
        Origin calldata,
        bytes32,
        bytes calldata,
        address,
        bytes calldata
    ) internal override {}

    /// @notice 被 EndpointV2.lzCompose 调用，处理 BaseOApp.sendCompose 过来的包
    function lzCompose(
        address _oApp,
        bytes32 /*_guid*/,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) external payable override {
        // 只接受 Endpoint 调用 + 来自指定 baseOApp 的 composed 消息
        require(msg.sender == address(endpoint), "AckComposerOApp: only endpoint");
        require(_oApp == baseOApp, "AckComposerOApp: invalid oApp");

        // 对应 BaseOApp 里：composeMsg = abi.encode(srcEid, srcOAppOnArb, "got it");
        (uint32 srcEid, bytes32 srcOAppOnArb, string memory ackMsg) =
            abi.decode(_message, (uint32, bytes32, string));

        // 把 bytes32 sender 转回来（如果你需要用 address 类型）
        address arbOApp = address(uint160(uint256(srcOAppOnArb)));

        // payload 设计为 Arb 侧 _lzReceive 能识别的格式：这里只传 string 即可
        bytes memory payload = abi.encode(ackMsg);

        // 为 Arb 侧 lzReceive 配置一点 gas（数值可以按你实际逻辑调整）
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(80_000, 0);

        // 用当前 msg.value 作为这次回 Arb 的 fee（native）
        _lzSend(
            srcEid,                 // Arb eid
            payload,
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)     // refund（这里 msg.sender = endpoint）
        );
    }
}
