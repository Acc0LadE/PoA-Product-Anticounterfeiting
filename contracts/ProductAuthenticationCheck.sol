// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces for the ProductAuth, ManufacturerRegistry, DistributorTracker, and OwnershipTransfer contracts
interface IProductAuth {
    // returns (name, isAuthentic)
    function verifyProduct(string memory _id) external view returns (string memory, bool);
    // public mapping getter for the stored hash
    function productHashes(string memory _id) external view returns (bytes32);
    // public mapping getter for the Product struct:
    // (name, batchNumber, origin, manufacturer, isAuthentic)
    function products(string memory _id) external view returns (
        string memory, string memory, string memory, address, bool
    );
}

interface IManufacturerRegistry {
    function isRegisteredManufacturer(address _manufacturer) external view returns (bool);
}

interface IDistributorTracker {
    function getTransfers(string memory _productId)
      external view
      returns (uint[] memory timestamps, address[] memory froms, address[] memory tos);
}

interface IOwnershipTransfer {
    function getOwnershipHistory(string memory _productId)
      external view
      returns (address[] memory owners, uint[] memory timestamps);
}

contract ProductAuthenticationCheck {
    address public productAuthContract;
    address public manufacturerRegistryContract;
    address public distributorTrackerContract;
    address public ownershipTransferContract;

    constructor(
        address _productAuthContract,
        address _manufacturerRegistryContract,
        address _distributorTrackerContract,
        address _ownershipTransferContract
    ) {
        productAuthContract         = _productAuthContract;
        manufacturerRegistryContract= _manufacturerRegistryContract;
        distributorTrackerContract  = _distributorTrackerContract;
        ownershipTransferContract   = _ownershipTransferContract;
    }

    /// @notice Runs a full authenticity check over 4 modules:
    ///   1) Core flag
    ///   2) Hash match
    ///   3) Registered manufacturer
    ///   4) At least one distributor transfer
    ///   5) At least one ownership record
    function verifyProduct(
        string memory _productId,
        bytes32      _productHash
    ) public view returns (bool) {
        // --- 1) Core authenticity flag ---
        (, bool isAuthentic) = IProductAuth(productAuthContract).verifyProduct(_productId);
        if (!isAuthentic) {
            return false;
        }

        // --- 2) Hash match ---
        bytes32 stored = IProductAuth(productAuthContract).productHashes(_productId);
        if (stored != _productHash) {
            return false;
        }

        // --- 3) Manufacturer registered? ---
        // retrieve manufacturer from the products mapping
        (, , , address manufacturer, ) =
            IProductAuth(productAuthContract).products(_productId);
        bool okManu = IManufacturerRegistry(manufacturerRegistryContract)
                        .isRegisteredManufacturer(manufacturer);
        if (!okManu) {
            return false;
        }

        // --- 4) Distributor transfer exists? ---
        (uint[] memory times, , ) =
            IDistributorTracker(distributorTrackerContract)
              .getTransfers(_productId);
        if (times.length == 0) {
            return false;
        }

        // --- 5) Ownership history exists? ---
        (address[] memory owners, ) =
            IOwnershipTransfer(ownershipTransferContract)
              .getOwnershipHistory(_productId);
        if (owners.length == 0) {
            return false;
        }

        return true;
    }
}
