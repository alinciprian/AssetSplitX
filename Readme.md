### AssetSplitX

This dApp is meant to allow users to collectively buy an expensive item, each buyer becoming a fractional owner, proportional to the 
amount of shares the user bought. 

Each object that will be sold using the protocol will be split in 100 shares and 100 tokens will be issued. A crowdfunding 


[Organizer Creates Campaign]
        │
        ▼
[Campaign Smart Contract Deployed]
        │
        ▼
[Users Contribute Funds (ETH/Stablecoin)]
        │
        ▼
[Funds Escrowed in Contract] ───────┐
        │                           │
        │                        [If Goal Reached Before Deadline]
        │                           │
        ▼                           ▼
[Refundable if Campaign Fails]   [Mint Ownership Tokens]
                                    │
                                    ▼
                          [Distribute Tokens to Contributors]
                                    │
                                    ▼
                    [Asset Purchased via Multisig or DAO Custodian]
                                    │
                                    ▼
                    [Token Holders Can: Trade / Vote / Manage Asset]
                                    │
                                    ▼
                        [When Asset Sold → Proceeds to Contract]
                                    │
                                    ▼
                     [Token Holders Claim Profit Proportional to Tokens]
