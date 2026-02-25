// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMotoDEXnft.sol";

pragma solidity ^0.8.0;

contract USDTmoto is ERC20, Ownable {
    address public nftContract;
    error MustBeGameServer();
    error ReentrantGuard();

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    modifier nonReentrant() {
        if (_status == _ENTERED) revert ReentrantGuard();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor(
        address _nftContract
    ) ERC20("USDT motoDEX Token", "USDTmoto") Ownable(msg.sender) {
        nftContract = _nftContract;
        _mint(msg.sender, 88888 * 1000000000000000000);
    }

    function mint(address account, uint256 amount) public nonReentrant {
        if (IMotoDEXnft(nftContract).isGameServer(msg.sender) != true)
            revert MustBeGameServer();
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public nonReentrant {
        if (IMotoDEXnft(nftContract).isGameServer(msg.sender) != true)
            revert MustBeGameServer();
        _burn(account, amount);
    }
}
