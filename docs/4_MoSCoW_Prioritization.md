# MotoDEX MoSCoW Framework — Feature Prioritization

The MoSCoW method is used to define and prioritize the features for the MotoDEX smart contract and WebGL ecosystem, ensuring the most critical aspects are delivered first while defining a clear roadmap for the future.

## 1. Must Have (Critical for MVP Core Loop)
*Features that are absolutely non-negotiable for the product to function. Without them, the game cannot be played or monetized.*

*   **NFT Minting Engine (`MotoDEXnft.sol`)**:
    *   Ability to mint core assets: at least one Moto and one Track.
    *   Payment integration with native network coin (e.g., AVAX, ETH, BNB).
*   **Wallet Integration (Unity to Web3)**:
    *   Seamless connection to MetaMask/WalletConnect.
    *   Ability to read balances and verify ownership of NFTs before rendering them in the Unity garage.
*   **Core Gameplay Loop**:
    *   Playable Unity WebGL scene with physics for driving the Moto.
    *   Start and Finish line logic with a local timer.
*   **Secure Result Submission (`MotoDEX.sol`)**:
    *   A centralized Game Server that accepts race results.
    *   The smart contract function (`createOrUpdateGameSessionFor`) restricted to only authorized Game Servers to prevent generic cheating.

## 2. Should Have (Important, but not strictly MVP)
*Features that add significant value, polish, and economic depth to the ecosystem, but if delayed, the core game still functions.*

*   **Dynamic and ERC20 Pricing**:
    *   The `purchaseToken` function allowing users to buy NFTs using external stablecoins or the native `USDTmoto` token.
    *   Incremental pricing models (Bonding curves) that increase the price of Motos/Tracks based on supply (`_increasePrice`).
*   **Staking Mechanics**:
    *   The `addMoto` and `addTrack` functions that require locking the NFT into the main contract to earn or participate in competitive leaderboards, establishing economic sink holes.
*   **Ecosystem variety**:
    *   Multiple distinct Tracks (London, Dubai, etc.) and Motos (RedBuller, RoboHorse) with varied base speeds or visual models.
*   **Leaderboards**:
    *   Fetching on-chain epoch times and rendering global high-scores in the Unity UI.

## 3. Could Have (Nice to Have / Future Roadmap)
*Features that are desirable and can vastly improve the user experience or revenue, but are typically pushed to later updates.*

*   **Consumables and Upgrades**:
    *   Implementation of the Health Pills (`HEALTH_PILL_5`, `HEALTH_PILL_30`) enabling users to heal or boost their Motos for better times.
    *   A "Magic Box" randomized loot box (`MAGIC_BOX`) that rolls a random Moto upon purchase.
*   **Referral System**:
    *   The on-chain referral splits embedded in `purchaseToken`, giving a percentage of minting fees to promoters to drive organic marketing.
*   **Cross-Chain / Omnichain Support**:
    *   Omnichain logic that allows assets minted on one chain (like Avalanche) to be recognized or bridged to BNB or Polygon.

## 4. Won't Have (Out of Scope for current/immediate milestones)
*Features that have been explicitly identified as not necessary for the current iteration, preventing scope creep.*

*   **Fully Decentralized Anti-Cheat (ZK proofs)**:
    *   Relying entirely on zero-knowledge proofs for verifying physics inputs on-chain is too computationally expensive and complex for this stage; the project leans on the "Should Have" centralized Game Server validation model instead.
*   **Real-time Multiplayer PvP**:
    *   Synchronous 8-player racing using WebRTC/Netcode in Unity is out of scope. The game will focus on asynchronous Time Trials against the leaderboard.
*   **In-Game Custom Track Editor**:
    *   Allowing users to build tracks piece-by-piece and minting them dynamically is beyond the immediate scope of the initial Track NFTs.
