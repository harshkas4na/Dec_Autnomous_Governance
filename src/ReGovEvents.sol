// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ReGovEvents is Ownable {
    constructor() Ownable() {
    }

    event RequestProposalCreate(address proposer, string description);
    event RequestVote(address voter, uint256 proposalId, bool support);
    event RequestProposalExecute(uint256 id);

    function requestVote(uint256 proposalId, bool support) external onlyOwner {
        emit RequestVote(msg.sender, proposalId, support);
    }

    function requestProposalCreate(string memory description) external onlyOwner {
        emit RequestProposalCreate(msg.sender, description);
    }

    function requestProposalExecute(uint256 proposalId) external onlyOwner {
        emit RequestProposalExecute(proposalId);
    }
}
