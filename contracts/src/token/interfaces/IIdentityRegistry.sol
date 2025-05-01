//SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface IIdentityRegistry {
    function isVerified(address user) external view returns (bool);
    function registerUser(address user) external;
    function revokeUser(address user) external;
}
