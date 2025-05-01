//SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";
import {ICompliance} from "./interfaces/ICompliance.sol";

contract ERC3643Token is ERC20 {
    error ERC3643Token__SenderNotVerified();
    error ERC3643Token__RecipientNotVerified();
    error ERC3643Token__TransferNotCompliant();

    IIdentityRegistry public identityRegistry;
    ICompliance public compliance;

    constructor(string memory _name, string memory _symbol, address _identityRegistryAdress, address _complianceAddress)
        ERC20(_name, _symbol)
    {
        identityRegistry = IIdentityRegistry(_identityRegistryAdress);
        compliance = ICompliance(_complianceAddress);
    }

    // Override function to check for compliance before executing
    function transfer(address to, uint256 amount) public override returns (bool) {
        _checkCompliance(_msgSender(), to, amount);
        return super.transfer(to, amount);
    }

    // Override function to check for compliance before executing
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _checkCompliance(from, to, amount);
        return super.transferFrom(from, to, amount);
    }

    function _checkCompliance(address from, address to, uint256 amount) internal view {
        // Ensure both sender and recipient are verified in the identity registry
        if (!identityRegistry.isVerified(from)) revert ERC3643Token__SenderNotVerified();
        if (!identityRegistry.isVerified(to)) revert ERC3643Token__RecipientNotVerified();

        // Ensure the transfer complies with the rules
        if (!compliance.canTransfer(from, to, amount)) revert ERC3643Token__TransferNotCompliant();
    }
}
