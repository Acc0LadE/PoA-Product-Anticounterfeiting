// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OwnershipTransfer {
    address public admin;

    struct Ownership {
        string productId;
        address owner;
        uint timestamp;
    }

    mapping(string => Ownership[]) public productOwnershipHistory;

    event OwnershipTransferred(string productId, address owner, uint timestamp);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function transferOwnership(string memory _productId, address _newOwner) public {
        productOwnershipHistory[_productId].push(Ownership(_productId, _newOwner, block.timestamp));
        emit OwnershipTransferred(_productId, _newOwner, block.timestamp);
    }

    function getOwnershipHistory(string memory _productId) public view returns (Ownership[] memory) {
        return productOwnershipHistory[_productId];
    }
}
