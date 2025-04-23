// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DistributorTracker {
    address public admin;

    struct ProductTransfer {
        string productId;
        address from;
        address to;
        uint timestamp;
    }

    mapping(string => ProductTransfer[]) public productTransfers;

    event ProductTransferred(string productId, address from, address to, uint timestamp);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function transferProduct(string memory _productId, address _to) public {
        productTransfers[_productId].push(ProductTransfer(_productId, msg.sender, _to, block.timestamp));
        emit ProductTransferred(_productId, msg.sender, _to, block.timestamp);
    }

    function getTransfers(string memory _productId) public view returns (ProductTransfer[] memory) {
        return productTransfers[_productId];
    }
}
