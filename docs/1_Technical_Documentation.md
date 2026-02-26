# MotoDEX Technical Documentation

## 1. Introduction
MotoDEX is a blockchain-based game integrating NFT avatars (Motos), NFT Tracks, and a native token economy (USDTmoto) with a Unity WebGL frontend. This document outlines the technical stack, architectural decisions, and the implementation approach.

## 2. Technology Stack
*   **Smart Contracts**: Solidity (^0.8.4), Hardhat framework.
*   **Token Standards**: 
    *   ERC721 (NFTs) via OpenZeppelin for Motos, Tracks, and Health Pills.
    *   ERC20 for the native token (USDTmoto).
*   **Frontend / Game Engine**: Unity WebGL.
*   **Web3 Integration**: Web3.js / Ethers.js for connecting the Unity WebGL frontend to the blockchain via RPC providers.
*   **Networks Supported**: Multi-chain architecture with dynamic pricing based on network IDs (e.g., Avalanche, BSC, Polygon, Aurora, etc.).

## 3. Architecture Decisions
*   **Separation of Concerns**: The smart contract logic is separated into distinct contracts:
    *   `MotoDEXnft.sol`: Handles the minting, pricing, and URI storage for all NFTs (Motos, Tracks, Magic Boxes, Health Pills).
    *   `MotoDEX.sol`: Acts as the core gameplay and staking contract. It manages "staking" NFTs (`addTrack`, `addMoto`), game sessions, and records track completion times.
    *   `USDTmoto.sol`: An ERC20 token manageable by authorized Game Servers for in-game rewards and economy balancing.
*   **Game Server Authority**: To prevent cheating and ensure smooth gameplay, game outcomes (Track times, attempts) are reported by authorized centralized backends or oracle addresses (`gameServers`). The `MotoDEX` contract only accepts score updates (`createOrUpdateGameSessionFor`) from these verified addresses.
*   **Dynamic and Multi-Chain Pricing**: The NFT contract adjusts minting prices based on the deployed `networkId`, enabling seamless deployments across multiple EVM-compatible chains while maintaining relative USD values (using an internal oracle/fixed USD scale).
*   **Bonding Curve / Price Step**: Minting certain NFTs (like Motos) incrementally increases the base price to reward early adopters through `_increasePrice`.

## 4. Implementation Approach
*   **NFT Minting**: Users can mint NFTs using native coins (`purchase`) or supported ERC20 tokens (`purchaseToken`). 
*   **Gameplay Loop**: Users stake their Moto and Track NFTs into the main `MotoDEX` contract. The Unity WebGL game validates ownership and allows the player to race. Upon race completion, the Game Server pushes the time result on-chain.
*   **Security Mechanisms**: 
    *   `ReentrancyGuard` custom implementations across mutable functions to prevent re-entrancy attacks.
    *   `Ownable` permissions for contract configurations and game server whitelisting.
    *   `SafeERC20` used for secure token transfers.

## 5. Deployment Information
*   **Live App**: `https://app.motodex.dexstudios.games/?chain=avalanche`
*   **Primary Chain Focus**: Avalanche (with cross-chain support explicitly coded into the constructors).
