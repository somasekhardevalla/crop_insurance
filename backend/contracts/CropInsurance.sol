// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable {
    struct Policy {
        string location;
 
        uint256 premium;
        uint256 thresholdTemperature;
        uint256 settlementAmount;
        bool active;
    }
    constructor(address initialOwner) Ownable(initialOwner) {}

    mapping(address => Policy[]) public userPolicies;

    event PolicyCreated(address indexed policyHolder, string location, uint256 premium);
    event PolicyCancelled(address indexed policyHolder, string location);
    event ThresholdExceeded(address indexed policyHolder, string location, uint256 temperature, uint256 settlementAmount);

    function buyInsurance(string memory location, uint256 thresholdTemperature) external payable {
        require(msg.value > 0, "Premium must be greater than 0");
        require(thresholdTemperature > 0, "Threshold temperature must be greater than 0");

        Policy memory policy = Policy({
            location: location,
            premium: msg.value,
            thresholdTemperature: thresholdTemperature,
            settlementAmount: msg.value * 2, // Settlement amount is twice the premium
            active: true
        });

        userPolicies[msg.sender].push(policy);

        emit PolicyCreated(msg.sender, location, msg.value);
    }

    function cancelInsurance(uint256 policyIndex) external {
        require(policyIndex < userPolicies[msg.sender].length, "Invalid policy index");
        Policy storage policy = userPolicies[msg.sender][policyIndex];
        require(policy.active, "Policy is not active");

        emit PolicyCancelled(msg.sender, policy.location);

        // Refund premium to policy holder
        payable(msg.sender).transfer(policy.premium);

        // Deactivate policy
        policy.active = false;
    }

   function triggerSettlement(uint256 temperature, uint256 policyIndex) external {
    require(policyIndex < userPolicies[msg.sender].length, "Invalid policy index");
    Policy storage policy = userPolicies[msg.sender][policyIndex];
    require(policy.active, "Policy is not active");

    // Check if settlement amount exceeds contract balance
    require(address(this).balance >= policy.settlementAmount, "Insufficient contract balance for settlement");

    if (temperature >= policy.thresholdTemperature) {
        // Threshold temperature exceeded, trigger settlement payment
        require(payable(msg.sender).send(policy.settlementAmount), "Failed to send settlement amount");

        emit ThresholdExceeded(msg.sender, policy.location, temperature, policy.settlementAmount);

        // Deactivate policy after settlement
        policy.active = false;
    } else {
        // Temperature below threshold, no settlement triggered
        revert("Temperature below threshold, no settlement triggered");
    }
}


    function getUserPoliciesCount(address user) external view returns (uint256) {
        return userPolicies[user].length;
    }

    function getUserPolicy(address user, uint256 index) external view returns (string memory, uint256, uint256, uint256, bool) {
        require(index < userPolicies[user].length, "Invalid policy index");
        Policy storage policy = userPolicies[user][index];
        return (policy.location, policy.premium, policy.thresholdTemperature, policy.settlementAmount, policy.active);
    }
}
