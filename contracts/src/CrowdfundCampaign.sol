//SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {OwnershipToken} from "./token/OwnershipToken.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

/// @title CrowdfundCampaign
/// @author AlinCiprian
/// @notice This contract is meant to allow users to collectively buy and own an asset. Fractions of the asset can be bought, in exchange
/// for which users get ownership tokens. One ownership token equals 1% of the asset.

contract CrowdfundCampaign {
    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/
    error CrowdfundCampaign__InvalidSharesAmount();
    error CrowdfundCampaign__TransferFailed();
    error CrowdfundCampaign__CampaignFullyFunded();
    error CrowdfundCampaign__DeadlineExceed();
    error CrowdfundCampaign__CampaignNotFullyFunded();
    error CrowdfundCampaign__CampaignNotEnded();

    /// organizer of the campaign
    address public organizer;
    /// the name of the item that is put for sale
    string public itemName;
    /// the target price
    uint256 public itemPrice;
    /// Each share represent 1% of the asset
    uint256 public totalShares = 100;
    /// A user can buy a maximum of 34% of the asset so the minimum of owners will be three
    uint256 public maxSharesPerUser = 34;
    /// the value of each share computed from the target price divided by total shares;
    uint256 public sharePrice;
    /// The number will be decreased after each buy
    uint256 public sharesLeftToBuy = 100;
    /// deadline of the campaign. It ends on block.timestamp plus duration
    uint256 public deadline;

    /// turns true once the campaign is fully funded
    bool public funded = false;

    ///  The ownershipToken contract
    OwnershipToken ownershipToken;
    /// address of the stablecoin -> USDC
    address paymentToken;

    /// keeps track of how many shares each user aquired
    mapping(address => uint256) public sharesAquired;

    constructor(
        string memory _itemName,
        string memory _symbol,
        uint256 _itemPrice,
        uint256 _duration,
        address _compliance,
        address _identityregistry,
        address _paymentToken,
        address _organizer
    ) {
        itemName = _itemName;
        itemPrice = _itemPrice;
        deadline = block.timestamp + _duration;
        sharePrice = _itemPrice / totalShares;
        ownershipToken = new OwnershipToken(_itemName, _symbol, _compliance, _identityregistry);
        paymentToken = _paymentToken;
        organizer = _organizer;
    }

    /// @param _sharesAmount the amount of shares to be bought
    function buyShares(uint256 _sharesAmount) public {
        // Checks
        if (funded) revert CrowdfundCampaign__CampaignFullyFunded();
        if (block.timestamp > deadline) revert CrowdfundCampaign__DeadlineExceed();
        if (
            _sharesAmount <= 0 || _sharesAmount > sharesLeftToBuy || _sharesAmount > maxSharesPerUser
                || sharesAquired[msg.sender] + _sharesAmount > maxSharesPerUser
        ) {
            revert CrowdfundCampaign__InvalidSharesAmount();
        }

        uint256 paymentAmount = _sharesAmount * sharePrice;

        // Effects
        sharesAquired[msg.sender] += _sharesAmount;
        sharesLeftToBuy -= _sharesAmount;

        // Interactions
        // the payment amount is computed by multiplying the sharePrice with the amount of shares to be bought
        bool success = IERC20(paymentToken).transferFrom(msg.sender, address(this), paymentAmount);
        if (!success) revert CrowdfundCampaign__TransferFailed();

        // If all the shares has been sold we turn funded to true
        if (sharesLeftToBuy == 0) funded = true;
    }

    /// function redeemShares
    function redeemShares() external {
        // Checks - can only redeemShares if campaign is funded
        if (!funded) revert CrowdfundCampaign__CampaignNotFullyFunded();

        uint256 sharesToRedeem = sharesAquired[msg.sender];

        // Effects
        sharesAquired[msg.sender] = 0;

        // Interactions
        bool success = ownershipToken.transferFrom(address(this), msg.sender, sharesToRedeem);
        if (!success) revert CrowdfundCampaign__TransferFailed();
    }

    /// function withdrawFunds
}
