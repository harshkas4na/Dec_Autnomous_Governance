// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract ReGovEvents is Ownable {
    constructor() Ownable(msg.sender) {
    }

    mapping(uint256 => uint256) public VoteThresholds;
    mapping(uint256 => uint256) public VotingPeriods;
    mapping(uint256 => uint256) public votesFor;
    uint256 public proposalCount;

    event RequestProposalCreate(address proposer, string description,uint256 VotingThreshold,uint256 deadline);
    event RequestVote(address voter, uint256 proposalId, bool support);
    event RequestProposalExecute(uint256 id);

    function requestVote(uint256 proposalId, bool support) external onlyOwner {
        votesFor[proposalCount]=votesFor[proposalCount]+1;
        emit RequestVote(msg.sender, proposalId, support);
    }

    function requestProposalCreate(string memory description,uint256 VotingThreshold,uint256 deadline) external onlyOwner {
        proposalCount++;
        VoteThresholds[proposalCount] = VotingThreshold;
        VotingPeriods[proposalCount] = deadline;
        emit RequestProposalCreate(msg.sender, description,VotingThreshold,deadline);
    }

    //function to check as soon as block.timestamp > VotingPeriods[for any propsals till propsalCount] then execute the proposal


    //function to execute the propsal if votsFor a any proposal > VoteThresholds[for any propsals till propsalCount]



    function  ReaquestPropsalExecute(uint256 proposalId) external onlyOwner {
        emit RequestProposalExecute(proposalId);
    }
}
