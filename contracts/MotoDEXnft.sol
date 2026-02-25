// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact alex@cfc.io if you like to use code

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
//import "@openzeppelin/contracts/utils/Counters.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @custom:security-contact alex@openbisea.io
contract MotoDEXnft is
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable,
    ERC721Burnable
{
    //    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    error YouAreNotOwner();
    error MustBeBetween30and0();
    error MustBeGameServer();
    error CounterOverflow();
    error NotAvaliable();
    error WrongValue();
    error InvalidAddress();
    error ReentrantGuard();
    error MustBeHealthType();

    uint256 public referralPercent = 1;
    mapping(address => address) private _referrals;

    // moto:
    uint8 public constant RED_BULLER = 0;
    uint8 public constant ZEBRA_GRRR = 1;
    uint8 public constant ROBO_HORSE = 2;
    uint8 public constant METAL_EYES = 3;
    uint8 public constant BROWN_KILLER = 4;
    uint8 public constant CRAZY_LINE = 5;
    uint8 public constant MAGIC_BOX = 6;
    uint8 public constant HEALTH_PILL_5 = 7;
    uint8 public constant HEALTH_PILL_10 = 8;
    uint8 public constant HEALTH_PILL_30 = 9;
    uint8 public constant HEALTH_PILL_50 = 10;

    // tracks:
    uint8 public constant TRACK_LONDON = 100;
    uint8 public constant TRACK_DUBAI = 101;
    uint8 public constant TRACK_ABU_DHABI = 102;
    uint8 public constant TRACK_BEIJIN = 103;
    uint8 public constant TRACK_MOSCOW = 104;
    uint8 public constant TRACK_MELBURN = 105;
    uint8 public constant TRACK_PETERBURG = 106;
    uint8 public constant TRACK_TAIPEI = 107;
    uint8 public constant TRACK_PISA = 108;
    uint8 public constant TRACK_ISLAMABAD = 109;

    address[] gameServers;
    address public mainContract;
    address public omnichainContract;

    //    using Counters for Counters.Counter;

    uint private _tokenIdCounter;

    mapping(uint256 => uint8) public typeForId;

    mapping(uint256 => uint256) public healthForId;

    mapping(uint8 => string) public uriForType;

    mapping(uint8 => uint256) public counterForType;

    mapping(uint8 => uint256) public limitForType;

    mapping(uint8 => uint256) public priceForType;

    mapping(address => bool) public isTokenMustBurned;

    function setIsTokenMustBurned(
        address token,
        bool _isTokenMustBurned
    ) public onlyOwner {
        isTokenMustBurned[token] = _isTokenMustBurned;
    }

    function GetIsTokenMustBurned(address token) public view returns (bool) {
        return isTokenMustBurned[token];
    }

    mapping(address => uint) public oneTokenInUSD;

    function setOneTokenToUSD(
        address token,
        uint _oneTokenInUSD
    ) public onlyOwner {
        oneTokenInUSD[token] = _oneTokenInUSD;
    }

    function getOneTokenToUSD(address token) public view returns (uint) {
        return oneTokenInUSD[token];
    }

    mapping(uint256 => uint8) public percentForTrack;

    function getPercentForTrack(uint256 tokenId) public view returns (uint8) {
        return percentForTrack[tokenId];
    }

    function setPercentForTrack(
        uint256 tokenId,
        uint8 percent
    ) public onlyOwner {
        percentForTrack[tokenId] = percent;
    }

    function setPercentForTrackOwner(uint256 tokenId, uint8 percent) public {
        if (ownerOf(tokenId) != msg.sender) revert YouAreNotOwner();
        if (percent > 30) revert MustBeBetween30and0();
        percentForTrack[tokenId] = percent;
    }

    uint8[] public players;

    uint256 public priceMainCoinUSD = 1500000000000000000000;

    function getPriceMainCoinUSD() public view returns (uint256) {
        return priceMainCoinUSD;
    }

    function setPriceMainCoinUSD(uint256 price) public onlyOwner {
        priceMainCoinUSD = price;
    }

    //    AggregatorV3Interface internal priceFeed;
    //    AggregatorV3Interface internal priceFeedAuroraUSD;

    function getLatestPrice() public view returns (uint256, uint8) {
        if (priceMainCoinUSD > 0) return (priceMainCoinUSD, 18);
        return (type(uint).max, 18);
        //        (,int256 price,,,) = priceFeed.latestRoundData();
        //        uint8 decimals = priceFeed.decimals();
        //        return (uint256(), decimals);
    }

    function append(
        string memory a,
        string memory b
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    function setupType(
        uint8 _type,
        uint256 _price,
        uint256 _limit,
        string memory _uri
    ) private {
        priceForType[_type] = _price;
        limitForType[_type] = _limit;
        uriForType[_type] = append(
            "https://openbisea.mypinata.cloud/ipfs/QmQaER7thuksdaZ2vcZxM12GmfHg6Jvws2AW2e9mrhnSTe/",
            _uri
        );
    }

    uint256 public _networkId;

    constructor(
        uint256 networkId
    ) ERC721("motoDEXnft", "MOTO") Ownable(msg.sender) {
        // omnichainContract = _omnichainContract;

        _networkId = networkId;
        //        for (uint i; i < _gameServers.length; i++) {
        //            gameServers.push(_gameServers[i]);
        //        }
        //        gameServers = _gameServers;
        players = [
            RED_BULLER,
            ZEBRA_GRRR,
            ROBO_HORSE,
            METAL_EYES,
            BROWN_KILLER,
            CRAZY_LINE
        ];
        uint startPrice = 1 ether;
        //        if (networkId == 137 || networkId == 1313161554) startPrice = 5 ether;
        if (networkId == 1482601649) startPrice = 5000000;
        priceMainCoinUSD = 1500000000000000000000;

        setupType(RED_BULLER, startPrice, 0, "RedBuller");
        setupType(
            ZEBRA_GRRR,
            (startPrice * 120 ether) / 100 ether,
            0,
            "ZebraGrrrr"
        );
        setupType(
            ROBO_HORSE,
            (startPrice * 140 ether) / 100 ether,
            0,
            "RoboHorse"
        );
        setupType(
            METAL_EYES,
            (startPrice * 160 ether) / 100 ether,
            0,
            "MetalEyes"
        );
        setupType(
            BROWN_KILLER,
            (startPrice * 180 ether) / 100 ether,
            0,
            "BrownKiller"
        );
        setupType(
            CRAZY_LINE,
            (startPrice * 200 ether) / 100 ether,
            0,
            "CrazyLine"
        );
        setupType(
            MAGIC_BOX,
            (startPrice * 120 ether) / 100 ether,
            0,
            "MagicBox"
        );

        setupType(TRACK_LONDON, startPrice * 10, 0, "London");
        setupType(TRACK_DUBAI, startPrice * 10, 0, "Dubai");
        setupType(TRACK_ABU_DHABI, startPrice * 10, 0, "AbuDhabi");
        setupType(TRACK_BEIJIN, startPrice * 10, 0, "Beijing");
        setupType(TRACK_MOSCOW, startPrice * 10, 0, "Moscow");
        setupType(TRACK_MELBURN, startPrice * 10, 0, "Melburn");
        setupType(TRACK_PETERBURG, startPrice * 10, 0, "Peterburg");
        setupType(TRACK_TAIPEI, startPrice * 10, 0, "Taipei");
        setupType(TRACK_PISA, startPrice * 10, 0, "Pisa");
        setupType(TRACK_ISLAMABAD, startPrice * 10, 0, "Islamabad");

        setupType(
            HEALTH_PILL_5,
            (startPrice * 10 ether) / 100 ether,
            0,
            "HealthCapsule5"
        );
        setupType(
            HEALTH_PILL_10,
            (startPrice * 20 ether) / 100 ether,
            0,
            "HealthCapsule10"
        );
        setupType(
            HEALTH_PILL_30,
            (startPrice * 60 ether) / 100 ether,
            0,
            "HealthCapsule30"
        );
        setupType(HEALTH_PILL_50, startPrice, 0, "HealthCapsule50");

        //        if (networkId == 1) priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // ETH mainnet
        //        if (networkId == 4) priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);// ETH rinkeby
        //        if (networkId == 42) priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);// ETH kovan
        //        if (networkId == 56) priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);// BCS mainnet
        //        if (networkId == 97) {
        //            priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);// BCS testnet
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //        }
        //        if (networkId == 80001) {
        //            priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);// Matic testnet
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //        }
        //        if (networkId == 137) {
        //            priceFeed = AggregatorV3Interface(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);// Matic mainnet
        //            valueDecrease = 100000000000000000;
        //        }
        //        if (networkId == 1001) {
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //            priceMainCoinUSD = 283500000000000000;// klaytn testnet
        //        }
        //        if (networkId == 1281 || networkId == 9000 || networkId == 15555) {
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //            priceMainCoinUSD = 2835000000000000000000;// octopus testnet
        //        }
        //        if (networkId == 1313161554) {
        //            priceFeed = AggregatorV3Interface(0x842AF8074Fa41583E3720821cF1435049cf93565);// Aurora mainnet
        //            priceFeedAuroraUSD = AggregatorV3Interface(0xAe3F6EB5d0B4C0A4C8571aa1E40bE65FE84f4eE2);
        //            valueDecrease = 100000000000000;
        //        }
        //        if (networkId == 1313161555) {
        //            priceMainCoinUSD = 1500000000000000000000;// Aurora testnet
        //            valueDecrease = 100000000000000;
        //            setupType(TRACK_LONDON, 0.000005 ether, 300, "London");
        //        }
        //
        //        if (networkId == 5) {
        //            priceMainCoinUSD = 1500000000000000000000;// Goerli testnet
        //            valueDecrease = 100;
        //            setupType(TRACK_LONDON, 0.000005 ether, 300, "London");
        //        }

        //        if (networkId == 1029) {
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //            priceMainCoinUSD = 2835000000000000000000000000000000;// BTTC testnet
        //            valueDecrease = 100;
        //        }
        //
        //        if (networkId == 50021) {
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //            priceMainCoinUSD = 1500000000000000000000;// GTON testnet
        //            valueDecrease = 100;
        //        }
        //        if (networkId == 108) {
        //            priceMainCoinUSD = 3000000000000000;// thundercore mainnet
        //            valueDecrease = 100;
        //        }
        //        if (networkId == 18) {
        //            priceMainCoinUSD = 3000000000000000;// thundercore testnet
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //            valueDecrease = 100;
        //        }
        //        if (networkId == 719) {
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //            priceMainCoinUƒSD = 1500000000000000000000;// Shibarium testnet
        //            valueDecrease = 100;
        //        }
        //        if (networkId == 7001) {
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //            priceMainCoinUSD = 1500000000000000000000;//  testnet
        //            valueDecrease = 100;
        //        }
        //        if (networkId == 5001) {
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //            priceMainCoinUSD = 1500000000000000000000;//  testnet
        //            valueDecrease = 100;
        //        }
        //        if (networkId == 15557) {
        //            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
        //            priceMainCoinUSD = 1500000000000000000000;//  testnet
        //            valueDecrease = 100;
        //        }
        if (networkId == 17777) {
            priceMainCoinUSD = 1500000000000000000;
            valueDecrease = 10000;
        }
        if (networkId == 5000) {
            priceMainCoinUSD = 420000000000000000;
            valueDecrease = 100;
        }
        if (networkId == 8453) {
            priceMainCoinUSD = 1500000000000000000000;
            valueDecrease = 100;
        }
        if (networkId == 88002) {
            priceMainCoinUSD = 1500000000000000000000;
            valueDecrease = 100;
        }
        if (networkId == 1001) {
            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
            priceMainCoinUSD = 1500000000000000000000; //  testnet
            valueDecrease = 100;
        }
        if (networkId == 10243) {
            setupType(TRACK_LONDON, 0.05 ether, 300, "London");
            priceMainCoinUSD = 1500000000000000000000; //  testnet
            valueDecrease = 100;
        }
        if (networkId == 169) {
            priceMainCoinUSD = 1500000000000000000000;
            valueDecrease = 100;
        }
        if (networkId == 2359) {
            priceMainCoinUSD = 1500000000000000000000;
            valueDecrease = 100;
        }
        if (networkId == 7001) {
            priceMainCoinUSD = 1500000000000000000000;
            setupType(RED_BULLER, 0.001 ether, 300, "London");
            valueDecrease = 100;
        }
        if (networkId == 7000) {
            priceMainCoinUSD = 1200000000000000000;
            valueDecrease = 100;
        }
        if (networkId == 14) {
            priceMainCoinUSD = 20000000000000000;
            valueDecrease = 100;
        }

        if (networkId == 20000000000000000) {
            // reef chain
            priceMainCoinUSD = 4953000000000000;
            valueDecrease = 100;
        }
        if (networkId == 39) {
            priceMainCoinUSD = 13000000000000000;
            valueDecrease = 100;
        }
        if (networkId == 1043) {
            priceMainCoinUSD = 0.05 ether;
            valueDecrease = 100;
        }
        if (networkId == 1284) {
            priceMainCoinUSD = 0.05 ether;
            valueDecrease = 100;
        }
        if (networkId == 5031) {
            priceMainCoinUSD = 0.2 ether;
            valueDecrease = 1000000;
        }
    }

    function getReferral(address buyer) public view returns (address) {
        return _referrals[buyer];
    }

    function _setReferral(address buyer, address referral) public onlyOwner {
        _referrals[buyer] = referral;
    }

    function setUriForType(string memory uri, uint8 typeNft) public onlyOwner {
        uriForType[typeNft] = uri;
    }

    function setLimitForType(uint256 limit, uint8 typeNft) public onlyOwner {
        limitForType[typeNft] = limit;
    }

    function setPriceForType(uint256 price, uint8 typeNft) public onlyOwner {
        priceForType[typeNft] = price;
    }

    function setHealthForId(uint256 tokenId, uint256 health) public {
        if (isGameServer(msg.sender) != true && msg.sender != owner())
            revert MustBeGameServer();
        healthForId[tokenId] = health;
    }

    function setGameServers(address[] memory _gameServers) public onlyOwner {
        delete gameServers;
        for (uint i; i < _gameServers.length; i++) {
            gameServers.push(_gameServers[i]);
        }
    }

    function isGameServer(address wallet) public view returns (bool) {
        for (uint i; i < gameServers.length; i++) {
            if (gameServers[i] == wallet) return true;
        }
        return false;
    }

    function setMainContract(address _mainContract) public onlyOwner {
        mainContract = _mainContract;
    }

    function getMainContract() public view returns (address) {
        return mainContract;
    }

    function setOmnichainContract(address _omnichainContract) public onlyOwner {
        omnichainContract = _omnichainContract;
    }

    function getOmnichainContract() public view returns (address) {
        return omnichainContract;
    }

    function approveMainContract(address to, uint256 tokenId) public {
        if (msg.sender != mainContract) revert YouAreNotOwner();
        _approve(to, tokenId, address(0));
    }

    function getPriceForType(uint8 typeNft) public view returns (uint256) {
        return priceForType[typeNft];
    }

    function getLimitForType(uint8 typeNft) public view returns (uint256) {
        return limitForType[typeNft];
    }

    function getLimitsAndCounters() public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](40);
        for (uint256 x = 0; x < 10; x++) {
            result[x] = counterForType[uint8(x)];
        }
        for (uint256 x = 10; x < 20; x++) {
            result[x] = limitForType[uint8(x - 10)];
        }
        for (uint256 x = 20; x < 30; x++) {
            result[x] = counterForType[uint8(x + 100 - 20)];
        }
        for (uint256 x = 30; x < 40; x++) {
            result[x] = limitForType[uint8(x - 30 + 100)];
        }
        return result;
    }

    function getUriForType(uint8 typeNft) public view returns (string memory) {
        return uriForType[typeNft];
    }

    function getHealthForId(uint256 tokenId) public view returns (uint256) {
        return healthForId[tokenId];
    }

    function getTypeForId(uint256 tokenId) public view returns (uint8) {
        return typeForId[tokenId];
    }

    function _increasePrice(uint8 typeNft) private {
        uint256 currentPrice = priceForType[typeNft];
        uint256 index = 100;
        if (typeNft >= TRACK_LONDON) index = 10;
        if (typeNft >= HEALTH_PILL_5 && typeNft <= HEALTH_PILL_30) index = 1000;
        priceForType[typeNft] = currentPrice + (currentPrice / (index));
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        // Effects first (checks-effects-interactions pattern)
        _tokenIdCounter = _tokenIdCounter + 1;
        // Interactions last
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _safeMintType(
        address to,
        string memory uri,
        uint8 typeNft,
        bool needURI
    ) private {
        uint256 counter = counterForType[typeNft];
        counterForType[typeNft] = counter + 1;
        if (limitForType[typeNft] > 0 && counter > limitForType[typeNft])
            revert CounterOverflow();
        uint256 tokenId = _tokenIdCounter;
        // Effects first (checks-effects-interactions pattern)
        typeForId[tokenId] = typeNft;
        _increasePrice(typeNft);
        healthForId[tokenId] = priceForType[typeNft];
        if (typeNft >= TRACK_LONDON) percentForTrack[tokenId] = 30;
        _tokenIdCounter = _tokenIdCounter + 1;
        // Interactions last
        _safeMint(to, tokenId);
        if (needURI) _setTokenURI(tokenId, uri);
    }

    function safeMintType(
        address to,
        string memory uri,
        uint8 typeNft
    ) public onlyOwner {
        _safeMintType(to, uri, typeNft, true);
    }

    function safeMintTypeBatch(
        address[] memory to,
        uint8[] memory typesNft
    ) public onlyOwner {
        for (uint256 x = 0; x < typesNft.length; x++) {
            _safeMintType(to[x], "", typesNft[x], false);
        }
    }

    function mintAdmin(address to, uint8 typeNft) public {
        if (!(isGameServer(msg.sender) == true || msg.sender == owner()))
            revert YouAreNotOwner();
        _safeMintType(to, "", typeNft, false);
    }

    function valueInMainCoin(uint8 typeNft) public view returns (uint256) {
        uint256 priceMainToUSDreturned;
        uint8 decimals;
        (priceMainToUSDreturned, decimals) = getLatestPrice();
        uint256 valueToCompare = (priceForType[typeNft] * (10 ** decimals)) /
            (priceMainToUSDreturned);
        return valueToCompare;
    }

    function random() private view returns (uint) {
        return
            uint(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        tx.origin,
                        gasleft(),
                        block.number,
                        players
                    )
                )
            ) % players.length;
    }

    event Purchase(
        address indexed from,
        uint256 value,
        uint8 typeNft,
        uint8 finalTypeNft,
        address token
    );

    uint public valueDecrease = 100000000;

    function setValueDecrease(uint _valueDecrease) public onlyOwner {
        valueDecrease = _valueDecrease;
    }

    address public usdt;

    function getUSDT() public view returns (address) {
        return usdt;
    }

    function setUSDT(address _usdt) public onlyOwner {
        usdt = _usdt;
    }

    function getPriceForTypeToken(
        uint8 typeNft,
        address token
    ) public view returns (uint256) {
        //        if (token == address(0x8BEc47865aDe3B172A928df8f990Bc7f2A3b9f79) && _networkId == 1313161554) {
        //            int256 price;
        //            uint8 decimals;
        //            if (address(priceFeedAuroraUSD) == address(0)) {
        //                price = 25000000;
        //                decimals = 8;
        //            } else {
        //                (,price,,,) = priceFeedAuroraUSD.latestRoundData();
        //                decimals = priceFeedAuroraUSD.decimals();
        //            }
        //            return priceForType[typeNft] * (10 ** decimals) / uint256(price);
        //        }
        if (getOneTokenToUSD(token) > 0)
            return (priceForType[typeNft] * 1 ether) / getOneTokenToUSD(token);

        if (
            token == usdt &&
            (_networkId == 503129905 || _networkId == 1482601649)
        ) {
            return priceForType[typeNft];
        }
        return type(uint).max;
    }

    function purchaseOmnichain(
        uint8 typeNft,
        address receiver,
        uint256 value,
        address zrc20
    ) external {
        if (
            !(omnichainContract != address(0) &&
                msg.sender == omnichainContract)
        ) revert YouAreNotOwner();

        uint8 finalTypeNft = typeNft;

        if (typeNft == MAGIC_BOX) {
            finalTypeNft = uint8(random());
        }

        _safeMintType(receiver, "", finalTypeNft, false);
        emit Purchase(receiver, value, typeNft, finalTypeNft, zrc20);
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function networkValidationFor(address token) public view {
        if (token == address(0)) {
            if (_networkId == 503129905 || _networkId == 1482601649)
                revert NotAvaliable(); // for SKALE no main coin
        } else {
            if (token != usdt && getOneTokenToUSD(token) == 0) {
                revert NotAvaliable();
            }
        }
    }

    function purchaseToken(
        uint8 typeNft,
        address referral,
        address token
    ) public nonReentrant {
        networkValidationFor(token);
        //        if(!((token == address(0x8BEc47865aDe3B172A928df8f990Bc7f2A3b9f79) && _networkId == 1313161554) || ((token == usdt && (_networkId == 503129905 || _networkId == 1482601649))))) revert NotAvaliable();
        uint8 finalTypeNft = typeNft;

        if (typeNft == MAGIC_BOX) {
            finalTypeNft = uint8(random());
        }
        if (
            referral != address(0x0) || _referrals[msg.sender] != address(0x0)
        ) {
            if (_referrals[msg.sender] == address(0x0)) {
                if (!(referral == address(referral))) revert InvalidAddress();
                if (isContract(referral)) revert InvalidAddress();
                _referrals[msg.sender] = referral;
            } else referral = _referrals[msg.sender];

            uint256 referralFee = (getPriceForTypeToken(typeNft, token) *
                (referralPercent)) / (100);
            IERC20(token).safeTransferFrom(msg.sender, referral, referralFee);
            IERC20(token).safeTransferFrom(
                msg.sender,
                owner(),
                getPriceForTypeToken(typeNft, token) - (referralFee)
            );
        } else {
            IERC20(token).safeTransferFrom(
                msg.sender,
                owner(),
                getPriceForTypeToken(typeNft, token)
            );
        }
        _safeMintType(msg.sender, "", finalTypeNft, false);
        emit Purchase(
            msg.sender,
            getPriceForTypeToken(typeNft, token),
            typeNft,
            finalTypeNft,
            token
        );
    }

    function purchaseTokenBatch(
        uint8[] memory typesNft,
        address referral,
        address token
    ) public nonReentrant {
        networkValidationFor(token);

        //        if (!(token == address(0x8BEc47865aDe3B172A928df8f990Bc7f2A3b9f79) && _networkId == 1313161554) || ((token == usdt && (_networkId == 503129905 || _networkId == 1482601649)))) revert NotAvaliable();
        uint256 totalValueToPay = 0;
        for (uint256 x = 0; x < typesNft.length; x++) {
            totalValueToPay =
                totalValueToPay +
                getPriceForTypeToken(typesNft[x], token);
        }

        if (
            referral != address(0x0) || _referrals[msg.sender] != address(0x0)
        ) {
            if (_referrals[msg.sender] == address(0x0)) {
                if (!(referral == address(referral))) revert InvalidAddress();
                if (isContract(referral)) revert InvalidAddress();
                _referrals[msg.sender] = referral;
            } else referral = _referrals[msg.sender];

            uint256 referralFee = (totalValueToPay * (referralPercent)) / (100);
            IERC20(token).safeTransferFrom(msg.sender, referral, referralFee);
            IERC20(token).safeTransferFrom(
                msg.sender,
                owner(),
                totalValueToPay - (referralFee)
            );
        } else {
            IERC20(token).safeTransferFrom(
                msg.sender,
                owner(),
                totalValueToPay
            );
        }
        for (uint256 y = 0; y < typesNft.length; y++) {
            uint8 finalTypeNft = typesNft[y];
            if (typesNft[y] == MAGIC_BOX) {
                finalTypeNft = uint8(random());
            }
            _safeMintType(msg.sender, "", finalTypeNft, false);
            emit Purchase(
                msg.sender,
                totalValueToPay,
                typesNft[y],
                finalTypeNft,
                token
            );
        }
    }

    function purchase(
        uint8 typeNft,
        address referral
    ) public payable nonReentrant {
        networkValidationFor(address(0));

        if (msg.value < valueInMainCoin(typeNft) - (valueDecrease))
            revert WrongValue();
        uint8 finalTypeNft = typeNft;

        if (typeNft == MAGIC_BOX) {
            finalTypeNft = uint8(random());
        }
        if (
            referral != address(0x0) || _referrals[msg.sender] != address(0x0)
        ) {
            if (_referrals[msg.sender] == address(0x0)) {
                if (!(referral == address(referral))) revert InvalidAddress();
                if (isContract(referral)) revert InvalidAddress();
                _referrals[msg.sender] = referral;
            } else referral = _referrals[msg.sender];

            uint256 referralFee = (msg.value * (referralPercent)) / (100);
            Address.sendValue(payable(referral), referralFee);
            Address.sendValue(payable(owner()), msg.value - (referralFee));
        } else {
            Address.sendValue(payable(owner()), msg.value);
        }
        _safeMintType(msg.sender, "", finalTypeNft, false);
        emit Purchase(msg.sender, msg.value, typeNft, finalTypeNft, address(0));
    }

    function purchaseBatch(
        uint8[] memory typesNft,
        address referral
    ) public payable nonReentrant {
        networkValidationFor(address(0));

        uint256 totalValueToPay = 0;
        for (uint256 x = 0; x < typesNft.length; x++) {
            totalValueToPay = totalValueToPay + valueInMainCoin(typesNft[x]);
        }
        uint256 value = msg.value;
        if (value < totalValueToPay - (valueDecrease)) revert WrongValue();

        if (
            referral != address(0x0) || _referrals[msg.sender] != address(0x0)
        ) {
            if (_referrals[msg.sender] == address(0x0)) {
                if (!(referral == address(referral))) revert InvalidAddress();
                if (isContract(referral)) revert InvalidAddress();
                _referrals[msg.sender] = referral;
            } else referral = _referrals[msg.sender];

            uint256 referralFee = (value * (referralPercent)) / (100);
            Address.sendValue(payable(referral), referralFee);
            Address.sendValue(payable(owner()), value - (referralFee));
        } else {
            Address.sendValue(payable(owner()), value);
        }

        for (uint256 y = 0; y < typesNft.length; y++) {
            uint8 finalTypeNft = typesNft[y];
            if (typesNft[y] == MAGIC_BOX) {
                finalTypeNft = uint8(random());
            }
            _safeMintType(msg.sender, "", finalTypeNft, false);
            emit Purchase(
                msg.sender,
                value,
                typesNft[y],
                finalTypeNft,
                address(0)
            );
        }
    }

    function _checkTypeHealth(uint256 tokenId) private view {
        uint8 typeForID = getTypeForId(tokenId);
        if (
            !(typeForID == HEALTH_PILL_5 ||
                typeForID == HEALTH_PILL_10 ||
                typeForID == HEALTH_PILL_30 ||
                typeForID == HEALTH_PILL_50)
        ) revert MustBeHealthType();
    }

    event AddHealthMoney(address indexed from, uint256 value);

    /*  getHealthForId(tokenId) // current level
        getPriceForType(getTypeForId(tokenId)) // full health level
        getPriceForType(getTypeForId(healthPillTokenId)) // health pill level*/

    function addHealthMoney(uint256 tokenId) public payable nonReentrant {
        networkValidationFor(address(0));
        if (
            msg.value < valueInMainCoin(getTypeForId(tokenId)) - (valueDecrease)
        ) revert WrongValue();
        healthForId[tokenId] = getPriceForType(getTypeForId(tokenId)); // fill to full if more than maximum
        Address.sendValue(payable(owner()), msg.value);
        emit AddHealthMoney(msg.sender, msg.value);
    }

    event AddHealthNFT(
        address indexed from,
        uint256 healthPillTokenId,
        uint256 value,
        uint256 healthDiff
    );

    function addHealthNFT(
        uint256 tokenId,
        uint256 healthPillTokenId
    ) public nonReentrant {
        if (msg.sender != ownerOf(healthPillTokenId)) revert YouAreNotOwner();

        _checkTypeHealth(healthPillTokenId);
        uint256 healthDiff = getPriceForType(getTypeForId(tokenId)) -
            (getHealthForId(tokenId));
        if (healthDiff < getPriceForType(getTypeForId(healthPillTokenId)))
            healthForId[tokenId] = getPriceForType(getTypeForId(tokenId));
        else
            healthForId[tokenId] =
                getHealthForId(tokenId) +
                (getPriceForType(getTypeForId(healthPillTokenId)));

        _burn(healthPillTokenId);
        emit AddHealthNFT(
            msg.sender,
            healthPillTokenId,
            getPriceForType(getTypeForId(healthPillTokenId)),
            healthDiff
        );
    }

    //    function _beforeTokenTransfer(address from,
    //        address to,
    //        uint256 firstTokenId,
    //        uint256 batchSize
    //    )
    //    internal
    //    override(ERC721, ERC721Enumerable)
    //    {
    //        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    //    }

    // The following functions are overrides required by Solidity.
    //
    //    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    //        super._burn(tokenId);
    //    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        bytes memory tempEmptyStringTest = bytes(super.tokenURI(tokenId));
        if (tempEmptyStringTest.length == 0)
            return uriForType[typeForId[tokenId]];
        else return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;
    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        if (_status == _ENTERED) revert ReentrantGuard();

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    function multicall(
        bytes[] calldata data
    ) public returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(
                data[i]
            );

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }

    event UpdateCounter(address indexed from);

    uint256 public counterTotal;

    function updateCounter() public {
        counterTotal++;
        emit UpdateCounter(msg.sender);
    }

    event UpdateCounterPayable(address indexed from, uint256 value);

    function updateCounterPayable() public payable {
        counterTotal++;
        Address.sendValue(payable(msg.sender), msg.value);
        emit UpdateCounterPayable(msg.sender, msg.value);
    }

    event UpdateCounterToken(
        address indexed from,
        address token,
        uint256 value
    );

    function updateCounterToken(address token, uint256 amount) public {
        counterTotal++;
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(token).safeTransfer(msg.sender, amount);
        emit UpdateCounterToken(msg.sender, token, amount);
    }

    function _withdrawSuperAdmin(
        address token,
        uint256 amount,
        uint256 tokenId,
        address nftContract
    ) public onlyOwner nonReentrant returns (bool) {
        if (amount > 0) {
            if (token == address(0)) {
                Address.sendValue(payable(msg.sender), amount);
                return true;
            } else {
                IERC20(token).safeTransfer(msg.sender, amount);
                return true;
            }
        } else {
            IERC721(nftContract).safeTransferFrom(
                address(this),
                msg.sender,
                tokenId
            );
        }
        return false;
    }

    fallback() external payable {
        // custom function code
    }

    receive() external payable {
        // custom function code
    }
}
