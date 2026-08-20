// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SimpleStaking {

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public rewardBalance;
    mapping(address => uint256) public lastUpdateTime;

    uint256 public totalStaked;

    uint256 public constant REWARD_RATE = 10;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    function stake() public payable {
        require(msg.value > 0, "Must stake ETH");

        _accrueReward(msg.sender);

        stakedBalance[msg.sender] += msg.value;
        totalStaked += msg.value;

        if (lastUpdateTime[msg.sender] == 0) {
            lastUpdateTime[msg.sender] = block.timestamp;
        }

        emit Staked(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");
        require(
            stakedBalance[msg.sender] >= _amount,
            "Insufficient staked balance"
        );

        _accrueReward(msg.sender);

        stakedBalance[msg.sender] -= _amount;
        totalStaked -= _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "ETH transfer failed");

        if (stakedBalance[msg.sender] == 0) {
            lastUpdateTime[msg.sender] = 0;
        }

        emit Withdrawn(msg.sender, _amount);
    }

    function calculateReward(address _user)
        public
        view
        returns (uint256)
    {
        uint256 currentReward = rewardBalance[_user];

        if (stakedBalance[_user] == 0) {
            return currentReward;
        }

        uint256 timeStaked =
            block.timestamp - lastUpdateTime[_user];

        uint256 newReward =
            stakedBalance[_user]
            * REWARD_RATE
            * timeStaked
            / 100
            / 365 days;

        return currentReward + newReward;
    }

    function claimReward() public {
        _accrueReward(msg.sender);

        uint256 reward = rewardBalance[msg.sender];

        require(reward > 0, "No rewards available");
        require(
            address(this).balance >= reward,
            "Insufficient contract balance"
        );

        rewardBalance[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: reward}("");
        require(success, "ETH transfer failed");

        emit RewardClaimed(msg.sender, reward);
    }

    function _accrueReward(address _user) internal {
        if (stakedBalance[_user] == 0) {
            lastUpdateTime[_user] = block.timestamp;
            return;
        }

        uint256 timeStaked =
            block.timestamp - lastUpdateTime[_user];

        uint256 newReward =
            stakedBalance[_user]
            * REWARD_RATE
            * timeStaked
            / 100
            / 365 days;

        rewardBalance[_user] += newReward;

        lastUpdateTime[_user] = block.timestamp;
    }

    receive() external payable {}
}