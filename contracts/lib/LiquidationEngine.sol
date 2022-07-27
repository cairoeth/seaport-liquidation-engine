// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { OrderParameters } from "./ConsiderationStructs.sol";

/**
 * @title Liquidation Engine
 * @author cairoeth
 * @notice Liquidation engine that can be inherited to run a Dutch auction
 *         for every ERC721 a contract receives.
 */
contract LiquidationEngine {

    /// Declaring Seaport structure objects
    OfferItem[] _offerItem;
    ConsiderationItem[] _considerationItem;
    OrderParameters _orderParameters;
    Order _order;

    /**
     * @dev ..
     */
    constructor() {

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
        _offerItem = OfferItem(
            ItemType.ERC721, 
            msg.sender, 
            _tokenId, 
            1, 
            1
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
        _considerationItem = ConsiderationItem(
            ItemType.NATIVE,
            address(0),
            0,
            150000000000000000000,
            0,
            payable(address(this))
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
            block.timestamp + 1 days,
            bytes32(0),
            globalSalt++,
            bytes32(0),
            1
        );

        // EIP 1271 Signature

        /**
         *   ========= Order ==========
         *   struct OrderParameters parameters;
         *   bytes signature;
         */
        // _order = Order(_orderParameters);

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
