// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";
import {ICompliance} from "./interfaces/ICompliance.sol";

contract OwnershipToken is ERC20Permit, ERC20Votes, Ownable {
    error ERC3643Token__SenderNotVerified();
    error ERC3643Token__RecipientNotVerified();
    error ERC3643Token__TransferNotCompliant();

    IIdentityRegistry public identityRegistry;
    ICompliance public compliance;

    uint256 public constant MAX_SUPPLY = 100 ether;

    constructor(
        string memory _name,
        string memory _symbol,
        address _identityRegistryAddress,
        address _complianceAddress
    ) ERC20(_name, _symbol) ERC20Permit(_name) Ownable(msg.sender) {
        identityRegistry = IIdentityRegistry(_identityRegistryAddress);
        compliance = ICompliance(_complianceAddress);
        _mint(msg.sender, MAX_SUPPLY);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _checkCompliance(_msgSender(), to, amount);
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _checkCompliance(from, to, amount);
        return super.transferFrom(from, to, amount);
    }

    function burnTokens() external onlyOwner {
        _burn(msg.sender, MAX_SUPPLY);
    }

    function _checkCompliance(address from, address to, uint256 amount) internal view {
        if (!identityRegistry.isVerified(from)) revert ERC3643Token__SenderNotVerified();
        if (!identityRegistry.isVerified(to)) revert ERC3643Token__RecipientNotVerified();
        if (!compliance.canTransfer(from, to, amount)) revert ERC3643Token__TransferNotCompliant();
    }

    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }

    function nonces(address owner) public view override(ERC20Permit) returns (uint256) {
        return super.nonces(owner);
    }
}
