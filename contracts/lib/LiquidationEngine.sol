// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { 
    OrderParameters,
    OfferItem,
    ConsiderationItem,
    Order
} from "./ConsiderationStructs.sol";

import {
    OrderType,
    BasicOrderType,
    ItemType,
    Side
} from "./ConsiderationEnums.sol";

import { ConsiderationInterface } from "../interfaces/ConsiderationInterface.sol";

/**
 * @title Liquidation Engine
 * @author cairoeth
 * @notice Liquidation engine that can be inherited to run a Dutch auction
 *         for every ERC721 the contract receives.
 */
contract LiquidationEngine {
    uint256 internal globalSalt;
    address public seaport;

    /// Declaring Seaport structure objects
    OfferItem[] _offerItem;
    ConsiderationItem[] _considerationItem;
    OrderParameters _orderParameters;
    Order[] _order;

    /**
     * @dev Declare the Seaport address
     */
    constructor(address _seaport) {
        seaport = _seaport;
    }
    
    /**
    * @dev Executes a Dutch auction for every ERC721 token received using Seaport
    **/
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata
    ) external returns (bytes4) {
        /**
         *   ========= OfferItem ==========
         *   ItemType itemType;
         *   address token;
         *   uint256 identifierOrCriteria;
         *   uint256 startAmount;
         *   uint256 endAmount;
         */
        _offerItem.push(
            OfferItem(
                ItemType.ERC721, 
                msg.sender, 
                _tokenId, 
                1, 
                1
            )
        );

        /**
         *   ========= ConsiderationItem ==========
         *   ItemType itemType;
         *   address token;
         *   uint256 identifierOrCriteria;
         *   uint256 startAmount;
         *   uint256 endAmount;
         *   address payable recipient;
         */
        _considerationItem.push(
            ConsiderationItem(
                ItemType.NATIVE,
                address(0),
                0,
                150000000000000000000, // 150 ETH starting -- can be modified to fit
                0,
                payable(address(this))
            )
        );

        /**
         *   ========= OrderParameters ==========
         *   address offerer;
         *   address zone;
         *   struct OfferItem[] offer;
         *   struct ConsiderationItem[] consideration;
         *   enum OrderType orderType;
         *   uint256 startTime;
         *   uint256 endTime;
         *   bytes32 zoneHash;
         *   uint256 salt;
         *   bytes32 conduitKey;
         *   uint256 totalOriginalConsiderationItems;
         */
        _orderParameters = OrderParameters(
            address(this), 
            address(0),
            _offerItem,
            _considerationItem,
            OrderType.FULL_RESTRICTED,
            block.timestamp,
            block.timestamp + 1 days, // End time: tommorow (in 24)
            bytes32(0),
            globalSalt++,
            bytes32(0),
            1
        );

        /**
         *   ========= Order ==========
         *   struct OrderParameters parameters;
         *   bytes signature;
         */
        _order.push(
            Order(
                _orderParameters,
                bytes("0xffff")
            )
        );

        bool validation = ConsiderationInterface(seaport).validate(_order);
        require(validation);

        return LiquidationEngine.onERC721Received.selector;
    }
}
