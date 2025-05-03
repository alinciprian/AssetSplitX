//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {
    ERC20Burnable, ERC20
} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";
import {ICompliance} from "./interfaces/ICompliance.sol";

/// @title OwnershipToken
/// @author AlinCiprian
/// @notice This contract is an implementation of an ERC20 Token with several conditions on top of it.
/// Whenever a collective buy campaign is succesful, a new ERC3643 contract will be deployed, with a total
/// of 100 tokens which will be minted to the campaign contract.

contract OwnershipToken is ERC20, ERC20Burnable, Ownable {
    error ERC3643Token__SenderNotVerified();
    error ERC3643Token__RecipientNotVerified();
    error ERC3643Token__TransferNotCompliant();
    error ERC3643Token__NotZeroAddress();
    error ERC3643Token__MintAmountIsZero();

    IIdentityRegistry public identityRegistry;
    ICompliance public compliance;

    // The total supply that will ever exist is 100 tokens, each one representing 1 % ownership of the entire asset
    uint256 totalSupply = 100;

    constructor(string memory _name, string memory _symbol, address _identityRegistryAdress, address _complianceAddress)
        ERC20(_name, _symbol)
        Ownable(msg.sender)
    {
        identityRegistry = IIdentityRegistry(_identityRegistryAdress);
        compliance = ICompliance(_complianceAddress);
        _mint(msg.sender, totalSupply);
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

    /// The entire amount of tokens is burnt.
    /// @dev Meant to be used once the asset they represent is sold.
    /// @dev It burns the entire supply at once
    function burnTokens() external onlyOwner {
        burn(totalSupply);
    }

    function _checkCompliance(address from, address to, uint256 amount) internal view {
        // Ensure both sender and recipient are verified in the identity registry
        if (!identityRegistry.isVerified(from)) revert ERC3643Token__SenderNotVerified();
        if (!identityRegistry.isVerified(to)) revert ERC3643Token__RecipientNotVerified();

        // Ensure the transfer complies with the rules
        if (!compliance.canTransfer(from, to, amount)) revert ERC3643Token__TransferNotCompliant();
    }
}
