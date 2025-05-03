// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CrowdfundCampaign} from "./CrowdfundCampaign.sol";

contract CampaignFactory {
    address[] public campaigns;

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
        address _organizer
    ) external {
        CrowdfundCampaign newCampaign = new CrowdfundCampaign(
            _itemName,
            _symbol,
            _itemPrice,
            _duration,
            _maxSharesPerUser,
            _compliance,
            _identityregistry,
            _paymentToken,
            _organizer
        );
        campaigns.push(address(newCampaign));
        uint256 deadline = block.timestamp + _duration * 1 hours;

        emit CampaignCreated(address(newCampaign), _organizer, _itemName, _itemPrice, deadline);
    }

    function getAllCampaigns() external view returns (address[] memory) {
        return campaigns;
    }
}
