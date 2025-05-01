// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ICompliance} from "../interfaces/ICompliance.sol";

contract Compliance is ICompliance {
    // Add checks here
    function canTransfer(address from, address to, uint256 amount) external pure override returns (bool) {
        return true; // Placeholder, allow all transfers.
    }
}
