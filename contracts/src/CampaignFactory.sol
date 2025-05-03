// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {CrowdfundCampaign} from "./CrowdfundCampaign.sol";
import {EscrowFunds} from "./EscrowFunds.sol";

/// @title CampaignFactory
/// @author AlinCiprian
/// @notice This contract is responsible for deploying and managing multiple CrowdfundCampaign contracts.
/// It serves as a factory pattern implementation, allowing organizers to create new asset crowdfunding campaigns.
///
/// The factory keeps track of all deployed campaign addresses and emits an event each time a new
/// campaign is created for off-chain indexing or frontend consumption.
///
/// @dev This implementation assumes that each deployed CrowdfundCampaign contract will handle
/// its own payment, ownership, and refund logic independently. The factory does not interact with
/// campaign funds or ownership tokens post-deployment.

contract CampaignFactory {
    uint256 public totalCampaigns;
    address[] public campaigns;
    mapping(address => address[]) public compaignsByOrganizer;
    mapping(address => address) public campaignToEscrow;

    event CampaignCreated(
        address campaignAddress, address organizer, string itemName, uint256 goalAmount, uint256 deadline
    );

    function createCampaign(
        string memory _itemName,
        string memory _symbol,
        uint256 _itemPrice,
        uint256 _duration,
        uint256 _maxSharesPerUser,
        address _compliance,
        address _identityregistry,
        address _paymentToken,
        address _beneficiary,
        address _authorizedParty
    ) external {
        /// deploy new escrow
        EscrowFunds newEscrowfunds = new EscrowFunds(_beneficiary, _authorizedParty, _paymentToken);

        /// deploy new campaign
        CrowdfundCampaign newCampaign = new CrowdfundCampaign(
            _itemName,
            _symbol,
            _itemPrice,
            _duration,
            _maxSharesPerUser,
            _compliance,
            _identityregistry,
            _paymentToken,
            msg.sender,
            address(newEscrowfunds)
        );

        campaignToEscrow[address(newCampaign)] = address(newEscrowfunds);
        campaigns.push(address(newCampaign));
        compaignsByOrganizer[msg.sender].push(address(newCampaign));
        uint256 deadline = block.timestamp + _duration * 1 hours;
        totalCampaigns++;

        emit CampaignCreated(address(newCampaign), msg.sender, _itemName, _itemPrice, deadline);
    }
}
