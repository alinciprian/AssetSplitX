// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract EscrowFunds {
    error EscrowFunds__NotAuthorized();
    error EscrowFunds__TransferFailed();

    /// the address where the funds will be sent
    address public beneficiary;
    /// the address authorized to release funds; AuthorizedParty could be a multisig wallet controled by the
    /// beneficiary and the crowdfundCampaign organizer
    address public authorizedParty;
    /// the token token that is used for payment
    IERC20 public paymentToken;

    modifier onlyAuthorized() {
        if (msg.sender != authorizedParty) revert EscrowFunds__NotAuthorized();
        _;
    }

    /// @param _beneficiary The address where funds will be trasnfered
    /// @param _authorizedParty The address authorized to release funds
    /// @param _paymentToken The token used for payment
    constructor(address _beneficiary, address _authorizedParty, address _paymentToken) {
        beneficiary = _beneficiary;
        authorizedParty = _authorizedParty;
        paymentToken = IERC20(_paymentToken);
    }

    /// This function will release the funds. Ideally, a multisig wallet acts as a authorizedParty
    function releaseFunds() external onlyAuthorized {
        uint256 amount = paymentToken.balanceOf(address(this));
        bool sent = paymentToken.transfer(beneficiary, amount);
        if (!sent) revert EscrowFunds__TransferFailed();
    }
}
