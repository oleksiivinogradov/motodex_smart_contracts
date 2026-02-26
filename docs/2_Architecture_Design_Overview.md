# MotoDEX Architecture Design Overview

## 1. Overview
The MotoDEX architecture is designed to bridge a rich frontend Unity WebGL game with a secure, decentralized EVM blockchain backend. It relies on a hybrid model where gameplay relies on centralized verification (Game Servers) to submit true results to decentralized smart contracts.

## 2. Main Components

### 2.1 WebGL Game Application (Frontend)
*   **Unity Engine**: Renders the races, menus, and user interface.
*   **Web3 Connector**: Integrates user wallets (e.g., MetaMask). Reads user NFT balances (Motos, Tracks) to unlock playable content.

### 2.2 Game Servers (Middleware)
*   **Validation Node**: Listens to the Unity game client's race completion events. Validates physics, completion time, and prevents cheating/speed hacks.
*   **Tx Relayer (Optional but recommended)**: Carries the private keys of the whitelisted `gameServers` to call `createOrUpdateGameSessionFor` and update the leaderboards on-chain.

### 2.3 Smart Contracts (On-Chain Backend)

#### A. MotoDEXnft.sol (The Asset Ledger)
*   **Role**: Manages the issuance and ownership of all game assets.
*   **Assets**: MOTO (Heroes), Tracks (Levels), Health Pills (Consumables).
*   **Mechanics**: Handles dynamic pricing, limits, and random generation (Magic Box).

#### B. MotoDEX.sol (The Game Engine / Staking)
*   **Role**: The core operational contract for gameplay.
*   **Mechanics**:
    *   **Staking (`addMoto`, `addTrack`)**: Users transfer their NFTs to this contract to register them for active gameplay.
    *   **Session Management**: Stores `GameSession` structs mapping Tracks and Motos to their `latestTrackTimeResult` and `attempts`.
    *   **Epoch & Rewards**: Contains logic for distributing epoch payments and fees (`syncEpochResultsMotos`).

#### C. USDTmoto.sol (The Economy)
*   **Role**: Native game currency.
*   **Mechanics**: Allowed game servers can mint/burn this token based on in-game events, integrating a play-to-earn/reward loop.

## 3. Workflows

### 3.1 Minting Workflow
1. User connects wallet to WebGL App.
2. User selects an NFT (Moto or Track) to buy.
3. Web App prompts MetaMask to call `purchase` or `purchaseToken` on `MotoDEXnft.sol`.
4. Smart contract mints NFT to the user's wallet.

### 3.2 Gameplay Workflow
1. User calls `addMoto` / `addTrack` on `MotoDEX.sol` to stake their assets and prepare for a race.
2. WebGL Game reads state and allows the user to play the corresponding Track with the corresponding Moto.
3. User completes the race in Unity.
4. Unity sends the cryptographically signed completion time to the centralized Game Server.
5. Game Server verifies the time and calls `createOrUpdateGameSessionFor` on the `MotoDEX` contract.
6. The contract saves the updated best time and attempt count on-chain.

## 4. Technical Structure Summary
*   **Client**: Browser -> Unity WebGL -> Web3.js
*   **Middleware**: Node.js / Go backend APIs for anti-cheat and Oracle relaying.
*   **Data Layer**: EVM Blockchain (Avalanche, etc.).
