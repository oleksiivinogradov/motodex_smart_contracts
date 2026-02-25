// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact alex@cfc.io if you like to use code

pragma solidity ^0.8.2;
interface IMotoDEXnft {
    function getTypeForId(uint256 tokenId) external view returns (uint8);
    function getHealthForId(uint256 tokenId) external view returns (uint256);
    function getPriceForType(uint8 typeNft) external view returns (uint256);
    function getPercentForTrack(uint256 tokenId) external view returns(uint8);
    function isGameServer(address wallet) external returns (bool);
    function approveMainContract(address to, uint256 tokenId) external;
    function getUSDT() external view returns (address);
    function purchaseOmnichain(uint8 typeNft, address receiver, uint256 value, address zrc20) external;
    function networkValidationFor(address token) external;
    function getOneTokenToUSD(address token) external view returns (uint);
}