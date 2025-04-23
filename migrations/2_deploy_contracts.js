const ProductAuth = artifacts.require("ProductAuth");
const ManufacturerRegistry = artifacts.require("ManufacturerRegistry");
const DistributorTracker = artifacts.require("DistributorTracker");
const OwnershipTransfer = artifacts.require("OwnershipTransfer");
const ProductAuthenticationCheck = artifacts.require(
  "ProductAuthenticationCheck"
);

module.exports = async function (deployer) {
  await deployer.deploy(ProductAuth);
  const productAuth = await ProductAuth.deployed();

  await deployer.deploy(ManufacturerRegistry);
  const manufacturerRegistry = await ManufacturerRegistry.deployed();

  await deployer.deploy(DistributorTracker);
  const distributorTracker = await DistributorTracker.deployed();

  await deployer.deploy(OwnershipTransfer);
  const ownershipTransfer = await OwnershipTransfer.deployed();

  await deployer.deploy(
    ProductAuthenticationCheck,
    productAuth.address,
    manufacturerRegistry.address,
    distributorTracker.address,
    ownershipTransfer.address
  );
};
