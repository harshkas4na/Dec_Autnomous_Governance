// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
// 0x9A6C54fa5A28367436809Aca3Ce9e4A42B331c1B
contract ReGovL1 is Ownable {
    uint256 public proposalCount;
    address private callbackSender;
    uint256 public votingPeriod;

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        uint256 deadline;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public votes;

    event ProposalCreated(uint256 id, address proposer, string description);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 id);
    event ProposalRejected(uint256 id);

    constructor(address _callbackSender, uint256 _votingPeriod) Ownable(msg.sender) {
        callbackSender = _callbackSender;
        votingPeriod = _votingPeriod;
    }

    // modifier onlyReactive() {
    //     if(msg.sender !=address(0)){
    //         require(msg.sender == callbackSender, "Unauthorized");
    //     }
    //     _;
    // }

    function createProposal(address /* sender */, address voter, string memory description) external  {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            proposer: voter,
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            deadline: block.timestamp + votingPeriod
        });

        emit ProposalCreated(proposalCount, voter, description);
    }

    function vote(address /* sender */, address voter, uint256 proposalId, bool support) external  {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting period has ended");
        require(!votes[proposalId][voter], "Already voted");

        if (support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        votes[proposalId][voter] = true;
        emit Voted(proposalId, voter, support);
    }

    function executeProposal(address /* sender */, uint256 proposalId) external  {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period not ended");
        require(!proposal.executed, "Already executed");

        if (proposal.votesFor > proposal.votesAgainst) {
            proposal.executed = true;
            emit ProposalExecuted(proposalId);
        } else {
            emit ProposalRejected(proposalId);
        }
    }
}
