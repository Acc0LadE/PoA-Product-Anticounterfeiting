// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProductAuth {
    address public admin;

    struct Product {
        string name;
        string batchNumber;
        string origin;
        address manufacturer;
        bool isAuthentic;
    }

    mapping(string => Product) public products;
    mapping(string => bytes32) public productHashes;

    event ProductRegistered(
        string   indexed productId,
        string             name,
        address            manufacturer,
        bytes32            productHash
    );
    event ProductVerified(string indexed productId, bool isAuthentic);
    event ProductHashVerified(string indexed productId, bool hashMatches);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerProduct(
        string  memory _id,
        string  memory _name,
        string  memory _batchNumber,
        string  memory _origin,
        address _manufacturer,
        bytes32 _hash
    ) public onlyAdmin {
        products[_id] = Product(_name, _batchNumber, _origin, _manufacturer, true);
        productHashes[_id] = _hash;
        emit ProductRegistered(_id, _name, _manufacturer, _hash);
    }

    function verifyProduct(string memory _id) public view returns (string memory, bool) {
        return (products[_id].name, products[_id].isAuthentic);
    }

    function verifyProductByHash(string memory _id, bytes32 _hash) public returns (bool) {
        bool matches = (productHashes[_id] == _hash);
        emit ProductHashVerified(_id, matches);
        return matches;
    }

    function markProductCounterfeit(string memory _id) public onlyAdmin {
        products[_id].isAuthentic = false;
        emit ProductVerified(_id, false);
    }
}
