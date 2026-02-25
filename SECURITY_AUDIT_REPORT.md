# MotoDEX Smart Contracts — Slither Security Analysis Report

**Date:** February 25, 2026  
**Tool:** Slither v0.10.4  
**Contracts Analyzed:** MotoDEX.sol, MotoDEXnft.sol, USDTmoto.sol, IMotoDEXnft.sol, IABSNFT.sol  
**Compiler:** Solidity 0.8.24

---

## Findings Summary

| Severity | Count |
|---|---|
| High | 0 |
| Medium | 19 |
| Low | 69 |
| Informational | 106 |
| Optimization | 6 |
| **Total** | **200** |

> The single High-severity finding (`incorrect-exp` in OpenZeppelin's `Math.mulDiv`) is a known false positive — the XOR operator `^` is used intentionally in the library. It is excluded from the count.

---

## Medium Severity Findings (19)

### M-1: divide-before-multiply

```
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#123-202)
performs a multiplication on the result of a division:
  - denominator = denominator / twos
  - inverse = (3 * denominator) ^ 2
```

**Instances:** 8 findings in OpenZeppelin `Math.mulDiv` (library code)

---

### M-2: divide-before-multiply

```
MotoDEX.syncEpochResultsBids() (contracts/MotoDEX.sol#958-1153) performs a multiplication on the result of a division:
  - amountToDistribute = gameBidsSumPerTrack[gameBid.trackId] * gameBid.amount / bidsWinSum
  - payments[paymentsCount] = EpochPayment(decreasedByHealthLevel(
      amountToDistribute * 10 / 100 * IMotoDEXnft(nftContract).getPercentForTrack(gameBid.trackId) / 100,
      gameBid.trackId), ...)
```

**Instances:** 2 findings in `syncEpochResultsBids`

---

### M-3: incorrect-equality

```
MotoDEXnft._checkTypeHealth(uint256) (contracts/MotoDEXnft.sol#873-881) uses a dangerous strict equality:
  - !(typeForID == HEALTH_PILL_5 || typeForID == HEALTH_PILL_10 || typeForID == HEALTH_PILL_30 ||
     typeForID == HEALTH_PILL_50 || typeForID == HEALTH_PILL_100)
```

---

### M-4: reentrancy-no-eth

```
Reentrancy in MotoDEXnft.purchaseToken(uint8,address,address) (contracts/MotoDEXnft.sol#696-740):
  External calls:
    - IERC20(token).safeTransferFrom(msg.sender,referral,referralFee)
    - IERC20(token).safeTransferFrom(msg.sender,owner(),getPriceForTypeToken(typeNft,token) - referralFee)
    - IERC20(token).safeTransferFrom(msg.sender,owner(),getPriceForTypeToken(typeNft,token))
    - _safeMintType(msg.sender,,finalTypeNft,false)
        - retval = IERC721Receiver(to).onERC721Received(...)
  State variables written after the call(s):
    - _safeMintType → priceForType[typeNft] = currentPrice + (currentPrice / index)
  MotoDEXnft.priceForType can be used in cross function reentrancies:
    - _increasePrice, _safeMintType, getPriceForType, getPriceForTypeToken, setPriceForType, setupType, valueInMainCoin
```

**Note:** Function protected by `nonReentrant` modifier.

---

### M-5: reentrancy-no-eth

```
Reentrancy in MotoDEXnft.purchaseTokenBatch(uint8[],address,address) (contracts/MotoDEXnft.sol#742-794):
  External calls:
    - IERC20(token).safeTransferFrom(msg.sender,referral,referralFee)
    - IERC20(token).safeTransferFrom(msg.sender,owner(),totalValueToPay - referralFee)
    - IERC20(token).safeTransferFrom(msg.sender,owner(),totalValueToPay)
    - _safeMintType(msg.sender,,finalTypeNft,false)
        - retval = IERC721Receiver(to).onERC721Received(...)
  State variables written after the call(s):
    - _safeMintType → priceForType[typeNft] = currentPrice + (currentPrice / index)
  MotoDEXnft.priceForType can be used in cross function reentrancies:
    - _increasePrice, _safeMintType, getPriceForType, getPriceForTypeToken, setPriceForType, setupType, valueInMainCoin
```

**Note:** Function protected by `nonReentrant` modifier.

---

### M-6: reentrancy-no-eth

```
Reentrancy in MotoDEXnft.purchase(uint8,address) (contracts/MotoDEXnft.sol#796-826):
  External calls:
    - Address.sendValue(address(referral),referralFee)
    - Address.sendValue(address(owner()),msg.value - referralFee)
    - Address.sendValue(address(owner()),msg.value)
    - _safeMintType(msg.sender,,finalTypeNft,false)
        - retval = IERC721Receiver(to).onERC721Received(...)
  State variables written after the call(s):
    - _safeMintType → priceForType[typeNft] = currentPrice + (currentPrice / index)
  MotoDEXnft.priceForType can be used in cross function reentrancies:
    - _increasePrice, _safeMintType, getPriceForType, getPriceForTypeToken, setPriceForType, setupType, valueInMainCoin
```

**Note:** Function protected by `nonReentrant` modifier.

---

### M-7: reentrancy-no-eth

```
Reentrancy in MotoDEXnft.purchaseBatch(uint8[],address) (contracts/MotoDEXnft.sol#828-871):
  External calls:
    - Address.sendValue(address(referral),referralFee)
    - Address.sendValue(address(owner()),value - referralFee)
    - Address.sendValue(address(owner()),value)
    - _safeMintType(msg.sender,,finalTypeNft,false)
        - retval = IERC721Receiver(to).onERC721Received(...)
  State variables written after the call(s):
    - _safeMintType → priceForType[typeNft] = currentPrice + (currentPrice / index)
  MotoDEXnft.priceForType can be used in cross function reentrancies:
    - _increasePrice, _safeMintType, getPriceForType, getPriceForTypeToken, setPriceForType, setupType, valueInMainCoin
```

**Note:** Function protected by `nonReentrant` modifier.

---

### M-8: reentrancy-no-eth

```
Reentrancy in MotoDEX.syncEpoch() (contracts/MotoDEX.sol#1276-1348):
  External calls:
    - IMotoDEXnft(nftContract).isGameServer(msg.sender) != true
    - Address.sendValue(address(payment.to),payment.amount)
  State variables written after the call(s):
    - _syncEpochDelete() → delete gameBids[i], gameBidsCount = 0,
      delete gameBidsSumPerTrack[trackTokenId], delete gameSessions[trackTokenId][motoTokenId],
      delete motoOwnersFeeAmount[motoTokenId]
  Cross function reentrancy targets:
    - gameBids, gameBidsCount, gameBidsSumPerTrack, gameSessions, motoOwnersFeeAmount
```

**Note:** Function protected by `nonReentrant` modifier.

---

### M-9: reentrancy-no-eth

```
Reentrancy in MotoDEX.syncEpoch() (contracts/MotoDEX.sol#1276-1348):
  External calls:
    - IMotoDEXnft(nftContract).isGameServer(msg.sender) != true
    - Address.sendValue(address(payment.to),payment.amount)
    - _syncEpochReturnMotos() → IERC721(nftContract).safeTransferFrom(...)
  State variables written after the call(s):
    - _syncEpochReturnMotos() → balanceOf--, delete motoOwners[motoTokenId]
  Cross function reentrancy targets:
    - balanceOf, motoOwners
```

**Note:** Function protected by `nonReentrant` modifier.

---

### M-10: reentrancy-no-eth

```
Reentrancy in MotoDEX._syncEpochReturnMotos() (contracts/MotoDEX.sol#1259-1274):
  External calls:
    - IERC721(nftContract).safeTransferFrom(address(this),motoOwners[motoTokenId],motoTokenId)
  State variables written after the call(s):
    - balanceOf--
    - delete motoOwners[motoTokenId]
  Cross function reentrancy targets:
    - fillMotosTracksIdsAddedToContract, getGameSessions, syncEpochResultsBids, syncEpochResultsMotos, tokenIdsAndOwners
```

**Note:** Called exclusively from `syncEpoch()` which is protected by `nonReentrant` modifier.

---

## Low Severity Findings (69)

| Check | Count | Description |
|---|---|---|
| `calls-loop` | 36 | External calls inside loops |
| `reentrancy-benign` | 14 | Benign reentrancy (no state impact) |
| `events-maths` | 6 | Missing arithmetic checks before events |
| `missing-zero-check` | 6 | Missing zero-address validation |
| `reentrancy-events` | 6 | Reentrancy leading to out-of-order events |
| `timestamp` | 1 | Block timestamp dependency |

---

## Informational Findings (106)

| Check | Count | Description |
|---|---|---|
| `too-many-digits` | 33 | Numeric literals with many digits |
| `naming-convention` | 32 | Non-conforming naming conventions |
| `costly-loop` | 12 | State variable changes inside loops |
| `assembly` | 7 | Inline assembly usage |
| `boolean-equal` | 6 | Comparison to boolean constant |
| `low-level-calls` | 6 | Low-level calls |
| `solc-version` | 5 | Solidity version issues |
| `cyclomatic-complexity` | 2 | High cyclomatic complexity |
| `pragma` | 1 | Different pragma directives |
| `dead-code` | 1 | Unused code |
| `missing-inheritance` | 1 | Missing inheritance |

---

## Optimization Findings (6)

| Check | Count | Description |
|---|---|---|
| `immutable-states` | 3 | State variables that could be `immutable` |
| `constable-states` | 2 | State variables that could be `constant` |
| `cache-array-length` | 1 | Array length not cached in loop |
