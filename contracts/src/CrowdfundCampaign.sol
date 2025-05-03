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
    error CrowdfundCampaign__RefundCriteriaNotMet();
    error CrowdfundCampaign__NothingToRefund();
    error CrowdfundCampaign__OnlyOrganizerCanCallThis();

    /// organizer of the campaign
    address public organizer;
    /// the name of the item that is put for sale
    string public itemName;
    /// the target price
    uint256 public itemPrice;
    /// amount that have already been raised
    uint256 totalRaised;
    /// Each share represent 1% of the asset
    uint256 public totalShares = 100;
    /// A user can only buy a certain amount of shares to promote decentralization. Depending on the price of the asset
    /// this will be determined individually.
    uint256 public maxSharesPerUser;
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

    /// keeps track of how much each user contributed
    mapping(address => uint256) public contributed;

    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event SharesBought(address indexed user, uint256 sharesAmount, uint256 contributedAmount);
    event SharesRedeemed(address indexed user, uint256 sharesAmount);
    event UserRefunded(address indexed user, uint256 refundAmount);

    /*//////////////////////////////////////////////////////////////////////////
                                  MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice - used to ensure input  is not zero
    modifier onlyOrganizer() {
        if (msg.sender != organizer) revert CrowdfundCampaign__OnlyOrganizerCanCallThis();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @param _itemName The name of the item
    /// @param _symbol Symbol of the item
    /// @param _itemPrice The target price
    /// @param _duration Duration of the campaign
    /// @param _maxSharesPerUser How many shares to allow each user to buy. Ex 25 means max 25% ownership per user.
    /// @param _compliance Address of the compliance contract
    /// @param _identityregistry Address of the identityRegistry contract
    /// @param _paymentToken Address of the payment token
    /// @param _organizer Address of the organizer
    constructor(
        string memory _itemName,
        string memory _symbol,
        uint256 _itemPrice,
        uint256 _duration,
        uint256 _maxSharesPerUser,
        address _compliance,
        address _identityregistry,
        address _paymentToken,
        address _organizer
    ) {
        itemName = _itemName;
        itemPrice = _itemPrice;
        maxSharesPerUser = _maxSharesPerUser;
        deadline = block.timestamp + _duration * 1 hours;
        sharePrice = _itemPrice / totalShares;
        ownershipToken = new OwnershipToken(_itemName, _symbol, _compliance, _identityregistry);
        paymentToken = _paymentToken;
        organizer = _organizer;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @param _sharesAmount the amount of shares to be bought
    function buyShares(uint256 _sharesAmount) external {
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
        contributed[msg.sender] += paymentAmount;
        sharesLeftToBuy -= _sharesAmount;
        totalRaised += paymentAmount;

        // Interactions
        // the payment amount is computed by multiplying the sharePrice with the amount of shares to be bought
        bool success = IERC20(paymentToken).transferFrom(msg.sender, address(this), paymentAmount);
        if (!success) revert CrowdfundCampaign__TransferFailed();
        emit SharesBought(msg.sender, _sharesAmount, paymentAmount);

        // If all the shares has been sold we turn funded to true
        if (sharesLeftToBuy == 0) funded = true;
    }

    /// Funtion used to allow users to redeem shares
    /// @dev function is meant to be used only if the campaign is succesful.
    function redeemShares() external {
        // Checks - can only redeemShares if campaign is funded
        if (!funded) revert CrowdfundCampaign__CampaignNotFullyFunded();

        uint256 sharesToRedeem = sharesAquired[msg.sender];

        // Effects
        sharesAquired[msg.sender] = 0;

        // Interactions
        bool success = ownershipToken.transferFrom(address(this), msg.sender, sharesToRedeem);
        if (!success) revert CrowdfundCampaign__TransferFailed();
        emit SharesRedeemed(msg.sender, sharesToRedeem);
    }

    /// function refund - !funded && deadline passed
    /// @dev function is meant to be used only if the campaign fails
    function refund() external {
        // Checks
        if (funded || block.timestamp < deadline) revert CrowdfundCampaign__RefundCriteriaNotMet();
        uint256 amountContributed = contributed[msg.sender];
        if (amountContributed == 0) revert CrowdfundCampaign__NothingToRefund();

        // Effects
        contributed[msg.sender] = 0;

        // Interactions
        bool success = IERC20(paymentToken).transfer(msg.sender, amountContributed);
        if (!success) revert CrowdfundCampaign__TransferFailed();

        emit UserRefunded(msg.sender, amountContributed);
    }

    /// function withdraw campaign funds
    /// @dev function is meant to be called only if the campaign ended succesfully
    function claimFunds() external onlyOrganizer {
        if (!funded) revert CrowdfundCampaign__CampaignNotFullyFunded();
        IERC20(paymentToken).transfer(msg.sender, totalRaised);

        /// NEED to implement escrow
    }
}
