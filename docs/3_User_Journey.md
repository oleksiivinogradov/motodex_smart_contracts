# MotoDEX User Journey

## Overview
This document outlines the full end-to-end user journey for interacting with the MotoDEX ecosystem from the initial onboarding to active gameplay and potential earnings. The application is deployed at: `https://app.motodex.dexstudios.games/?chain=avalanche`

## Step-by-Step Experience

### 1. Discovery and Connection
*   The user arrives at the primary WebGL URL.
*   The user clicks the **Connect Wallet** button.
*   A Web3 prompt (e.g., MetaMask, WalletConnect) appears, requesting connection to the Avalanche network.
*   The user approves the connection.
*   The game reads the user's connected wallet address and checks their balance of MOTO NFTs, Track NFTs, and USDTmoto.

### 2. The Marketplace (Minting & Buying)
*   **No Assets?** If the user has no Motos or Tracks, they are guided to the in-game Marketplace or Minting portal.
*   **Minting (`MotoDEXnft.sol`)**:
    *   The user selects a Moto type (e.g., *"RedBuller"* or a random *"MagicBox"*).
    *   They click **Buy**. The app calls either `purchase()` using native coin (AVAX) or `purchaseToken()` using an approved ERC20.
    *   An on-chain transaction is triggered.
    *   Once confirmed, the smart contract mints the NFT to the user. The Unity UI updates to show the newly acquired Moto in the user's garage.
    *   The user repeats the process to acquire a Track (e.g., *"London"* or *"Dubai"*).

### 3. Preparation & Staking (The Garage)
*   In the Garage menu, the user selects their preferred Moto and Track.
*   To play competitively or record times, the assets must be staked into the core game contract (`MotoDEX.sol`).
*   **Staking (`addMoto` / `addTrack`)**:
    *   The user clicks **Stake / Equip**.
    *   The Unity client prompts the wallet to approve the `MotoDEX` contract to manage the NFT (`approveMainContract`).
    *   The user signs the transaction.
    *   The UI confirms the staking process and unlocks the "Play" button for that specific track setup.

### 4. Active Gameplay
*   The user clicks **Race / Play**.
*   The game scene loads. The player drives the Moto around the Track as fast as possible, dodging obstacles or navigating turns natively rendered in Unity.
*   The race runs locally on the user's browser, handling physics and client-side logic.
*   *During gameplay*, the user might collect in-game items or reach checkpoints.

### 5. Race Completion & Validation
*   The user crosses the finish line.
*   Unity records the completion time, signs the data packet with the session token, and sends it to the MotoDEX backend Game Servers via HTTPS/WSS.
*   **Anti-Cheat**: The Game Server verifies the race duration against the physics limits of the chosen Moto to detect speed-hacking.
*   **On-Chain Recording**: The Game Server calls `createOrUpdateGameSessionFor()` on the `MotoDEX` smart contract to officially log the user's best time and attempt count.

### 6. Leaderboards & Rewards
*   The user returns to the main menu and views the Global Leaderboard.
*   The UI fetches the structured `GameSession` mapping from the blockchain to display rankings.
*   If the user achieved a top time during a specific "Epoch" or tournament period, the smart contract logic (`syncEpochResultsMotos`, `EpochPayment`) allocates a portion of the accumulated entry fees (or `USDTmoto`) to the winner.
*   The user can claim these rewards back to their wallet, completing the Play-to-Earn loop.
