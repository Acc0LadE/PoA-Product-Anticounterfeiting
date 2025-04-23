// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ManufacturerRegistry {
    address public admin;
    mapping(address => bool) public registeredManufacturers;

    event ManufacturerRegistered(address manufacturer);
    event ManufacturerDeregistered(address manufacturer);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyManufacturer() {
        require(registeredManufacturers[msg.sender], "Only registered manufacturers can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerManufacturer(address _manufacturer) public onlyAdmin {
        registeredManufacturers[_manufacturer] = true;
        emit ManufacturerRegistered(_manufacturer);
    }

    function deregisterManufacturer(address _manufacturer) public onlyAdmin {
        registeredManufacturers[_manufacturer] = false;
        emit ManufacturerDeregistered(_manufacturer);
    }
}
