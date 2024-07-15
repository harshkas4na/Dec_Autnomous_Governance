// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;
// 0x1B8F8E14a370e9f9B7BC47818cf4a88B2a9830b6


import '../IReactive.sol';
import '../ISubscriptionService.sol';

contract ReGovReactive is IReactive {

    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    uint256 private constant REQUEST_PROPOSAL_CREATE_TOPIC_0 = 0x10b6d2b6d98ae8d7bf6288a4567e5a2e7a82d5be126c0ca8c028a685ac7dba87;
    uint256 private constant REQUEST_PROPOSAL_EXECUTE_TOPIC_0 = 0xcfc536199fed6fc9a1800da06eff07bc51565c5b442f83cd2d96344089bb07e4;
    uint256 private constant REQUEST_VOTE_TOPIC_0 = 0x8131eb889128114273bfedf30bfe5aad1a8f3bbef5d40f786c44000e3361ed0a;

    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    bool private vm;

    ISubscriptionService private service;
    address private l1;

    constructor(address service_address, address _contract, address _l1) {
        
        service = ISubscriptionService(service_address);
        bytes memory payload1 = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _contract,
            REQUEST_PROPOSAL_CREATE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result1,) = address(service).call(payload1);
        if (!subscription_result1) {
            vm = true;
        }
        bytes memory payload2 = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _contract,
            REQUEST_PROPOSAL_EXECUTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result2,) = address(service).call(payload2);
        if (!subscription_result2) {
            vm = true;
        }
        bytes memory payload3 = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _contract,
            REQUEST_VOTE_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result3,) = address(service).call(payload3);
        if (!subscription_result3) {
            vm = true;
        }

        l1 = _l1;
        
    }

    

    modifier rnOnly() {
        require(!vm, "Reactive Network only");
        _;
    }

    modifier vmOnly() {
        // require(vm, "VM only");
        _;
    }

    function react(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes calldata data,
        uint256 /* block number */,
        uint256 /* op_code */
    ) external vmOnly {
        if (topic_0 == REQUEST_VOTE_TOPIC_0) {
            bool support = topic_3 > 0 ? true : false;
            bytes memory payload = abi.encodeWithSignature(
                "vote(address,address,uint256,bool)",
                address(0),
                address(uint160(topic_1)),
                topic_2,
                support
            );
            emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
        } else if (topic_0 == REQUEST_PROPOSAL_CREATE_TOPIC_0) {
            
            
            bytes memory payload = abi.encodeWithSignature(
                "createProposal(address,address,string)",
                address(0),
                address(uint160(topic_1)),
                data
            );
            emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
        } else if (topic_0 == REQUEST_PROPOSAL_EXECUTE_TOPIC_0) {
            bytes memory payload = abi.encodeWithSignature(
                "executeProposal(address,uint256)",
                address(0),
                topic_1
            );
            emit Callback(chain_id, l1, CALLBACK_GAS_LIMIT, payload);
        }
    }
}
