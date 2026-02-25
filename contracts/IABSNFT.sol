// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact alex@cfc.io if you like to use code

pragma solidity ^0.8.2;
interface IABSNFT {
    function mint(address to, string memory tokenUri) external;
}