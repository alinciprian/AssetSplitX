// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface ICompliance {
    function canTransfer(address from, address to, uint256 amount) external view returns (bool);
}
