//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IIdentityRegistry} from "../interfaces/IIdentityRegistry.sol";

contract IdentityRegistry is IIdentityRegistry {
    mapping(address => bool) public verifiedUsers;

    function isVerified(address user) external view override returns (bool) {
        return verifiedUsers[user];
    }

    function registerUser(address user) external override {
        verifiedUsers[user] = true;
    }

    function revokeUser(address user) external override {
        verifiedUsers[user] = false;
    }
}
