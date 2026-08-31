// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Crowdfunding {

    struct Campaign {
        address creator;
        uint256 goal;
        uint256 pledged;
        uint256 deadline;
        bool exists;
        bool withdrawn;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    function createCampaign(uint256 _goal, uint256 _duration) external {
       require(_goal > 0, "Invalid goal");
       require(_duration > 0, "Invalid duration");

       campaignCount++;
       campaigns[campaignCount] = Campaign({
           creator: msg.sender,
           goal: _goal,
           pledged: 0,
           deadline: block.timestamp + _duration,
           exists: true,
           withdrawn: false
       });
    }

    function contribute(uint256 _campaignId) external payable {
       Campaign storage campaign = campaigns[_campaignId];
       require(campaign.exists, "Campaign does not exist");
       require(block.timestamp < campaign.deadline, "Campaign has ended");
       require(msg.value > 0, "Contribution must be greater than 0");

       contributions[_campaignId][msg.sender] += msg.value;
       campaign.pledged += msg.value;
    }

    function withdrawFunds(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];

        require(campaign.exists, "Campaign does not exist");
        require(msg.sender == campaign.creator, "Only creator can withdraw");
        require(
            block.timestamp >= campaign.deadline,
            "Campaign is still active"
        );
        require(campaign.pledged >= campaign.goal, "Goal not reached");
        require(!campaign.withdrawn, "Funds already withdrawn");

        uint256 amount = campaign.pledged;

        campaign.withdrawn = true;

        (bool success, ) = payable(campaign.creator).call{value: amount}("");
        require(success, "Transfer failed");
    }

    function refund(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];

        require(campaign.exists, "Campaign does not exist");
        require(block.timestamp >= campaign.deadline, "Campaign is still active");
        require(campaign.pledged < campaign.goal, "Goal was reached");

        uint256 contributedAmount = contributions[_campaignId][msg.sender];
        require(contributedAmount > 0, "No contributions to refund");

        contributions[_campaignId][msg.sender] = 0;
        campaign.pledged -= contributedAmount;

        (bool success, ) = payable(msg.sender).call{value: contributedAmount}("");
        require(success, "Refund failed");
    }

}