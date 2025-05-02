### AssetSplitX

This dApp is meant to allow users to collectively buy an expensive item, each buyer becoming a fractional owner, proportional to the 
amount of shares the user bought. 

Each object that will be sold using the protocol will be split in 100 shares and 100 tokens will be issued. Users can buy a minimum of one
share and no fractional shares can be bought. If a user owns 10 tokens he owns 10% of the item.

For each item, a campaign will start. Users can contribute with funds that will be escrowed in the contract. If the sell price is not met,
meaning the 100 shares are not entirely sold, the campaign fails and users can withdraw their funds. 

If the goal is reached before the deadline the ownership tokens will be minted and distributed to the owners(or they can redeem?).

Token holders can trade their tokens, they can vote for actions like selling the item. Upon selling, the amount obtained will be escrowed and owners will claim funds proportional to the tokens. A fraction of the profit is charged by the protocol as a fee.


![alt text](image.png)

📌 Phase 1: Core Protocol Finalization (Smart Contracts)
✅ Finalize current CrowdfundCampaign contract:

✅ Integrate minting of OwnershipToken at funding completion (either pre-minted on deploy, or mint on full funding event).

✅ Ensure OwnershipToken includes compliance checks (if your existing one connects to IdentityRegistry/Compliance modules — good to go).

✅ Double check refund, redeem, and claim logic via Foundry fuzz + invariant tests.

✅ Implement Escrow contract (optional but highly recommended):

Holds funds until asset seller confirms transfer off-chain.

Organizer can claim funds only after asset escrow process completes.

✅ (Optional) DAO Governance Module:

Simple DAO with proposal + voting for post-campaign asset management (sell/lease/auction decisions).

Could be an upgrade later but worth designing for.

📌 Phase 2: Frontend Dapp Integration
✅ Build Next.js or Vite + React frontend

Campaign details display (name, price, progress bar, shares left, deadline countdown)

Buy Shares form (integrating with buyShares() function via ethers.js/viem)

User Dashboard: view purchased shares, contributed amount, redeemable tokens, refund status

✅ Connect to smart contracts via ethers.js/viem

✅ Add WalletConnect + MetaMask support

✅ Optional: display share ownership via OwnershipToken balance

📌 Phase 3: Post-Campaign Asset & Token Management
✅ Asset purchase event confirmation (off-chain process with event emission like AssetPurchased)

✅ Transfer OwnershipTokens to buyers via redeemShares()

✅ (Optional) Secondary market or internal peer-to-peer trading for OwnershipTokens

✅ (Optional) DAO governance proposals and voting module

📌 Phase 4: Security, Audit, & Compliance
✅ Complete Foundry fuzz + invariant testing
✅ Perform gas optimizations
✅ Run smart contract security audit (manual + using tools like Slither, Echidna, and MythX)

✅ (Optional) Integrate KYC/AML features if tokenizing real assets

Use IdentityRegistry + Compliance contract hooks

