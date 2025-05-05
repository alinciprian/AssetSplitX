// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {OwnershipToken} from "./token/OwnershipToken.sol";

contract Governor {
    enum ProposalState {
        Active,
        Executed,
        Cancelled
    }

    struct Proposal {
        uint256 id;
        string description;
        address target;
        uint256 value;
        bytes callData;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        ProposalState state;
        mapping(address => bool) hasVoted;
    }
}
