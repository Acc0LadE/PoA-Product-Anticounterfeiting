const express = require("express");
const { Web3 } = require("web3");
const cors = require("cors");
const bodyParser = require("body-parser");
const QRCode = require("qrcode");
const app = express();

app.use(cors());
app.use(bodyParser.json());

// Connect to Ganache
const web3 = new Web3("http://localhost:7545");

// Load ABIs and deployed addresses
const ProductAuthJSON = require("../build/contracts/ProductAuth.json");
const ProductAuthenticationCheckJSON = require("../build/contracts/ProductAuthenticationCheck.json");
const ManufacturerRegistryJSON = require("../build/contracts/ManufacturerRegistry.json");
const DistributorTrackerJSON = require("../build/contracts/DistributorTracker.json");
const OwnershipTransferJSON = require("../build/contracts/OwnershipTransfer.json");

const networkId = "1337"; // Ganache's default network

// Contracts initialization
const productAuth = new web3.eth.Contract(
  ProductAuthJSON.abi,
  ProductAuthJSON.networks[networkId].address
);
const productCheck = new web3.eth.Contract(
  ProductAuthenticationCheckJSON.abi,
  ProductAuthenticationCheckJSON.networks[networkId].address
);
const manufacturerRegistry = new web3.eth.Contract(
  ManufacturerRegistryJSON.abi,
  ManufacturerRegistryJSON.networks[networkId].address
);
const distributorTracker = new web3.eth.Contract(
  DistributorTrackerJSON.abi,
  DistributorTrackerJSON.networks[networkId].address
);
const ownershipTransfer = new web3.eth.Contract(
  OwnershipTransferJSON.abi,
  OwnershipTransferJSON.networks[networkId].address
);

// Check if address is contract owner
const isOwner = async (address) => {
  const owner = await productAuth.methods.owner().call();
  return owner.toLowerCase() === address.toLowerCase();
};

// 📦 Register new product
app.post("/api/products", async (req, res) => {
  const { productDetails, manufacturerAddress } = req.body;
  if (!(await isOwner(manufacturerAddress))) {
    return res.status(403).json({ error: "Unauthorized: Not contract owner" });
  }

  try {
    const hash = web3.utils.keccak256(JSON.stringify(productDetails));
    await productAuth.methods
      .registerProduct(
        productDetails.productId,
        productDetails.name,
        productDetails.batchNumber,
        productDetails.origin,
        hash
      )
      .send({ from: manufacturerAddress, gas: 3000000 });

    const qrCode = await QRCode.toDataURL(hash);
    res.json({ hash, qrCode });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 🔍 Verify product using ProductAuthenticationCheck contract
app.post("/api/verify", async (req, res) => {
  const { productId, hash } = req.body;

  try {
    const isValid = await productCheck.methods
      .verifyProduct(productId, hash)
      .call();
    res.json({ isValid });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 🏭 Register Manufacturer
app.post("/api/manufacturers/register", async (req, res) => {
  const { adminAddress, manufacturerAddress } = req.body;

  try {
    await manufacturerRegistry.methods
      .registerManufacturer(manufacturerAddress)
      .send({ from: adminAddress });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 🚚 Track Distributor
app.post("/api/distributors/track", async (req, res) => {
  const { productId, distributorAddress, fromAddress } = req.body;

  try {
    await distributorTracker.methods
      .trackDistributor(productId, distributorAddress)
      .send({ from: fromAddress });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 🔄 Transfer Ownership
app.post("/api/ownership/transfer", async (req, res) => {
  const { productId, newOwner, fromAddress } = req.body;

  try {
    await ownershipTransfer.methods
      .transferOwnership(productId, newOwner)
      .send({ from: fromAddress });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 🛠 Get Owner of a Product
app.get("/api/ownership/:productId", async (req, res) => {
  try {
    const currentOwner = await ownershipTransfer.methods
      .getCurrentOwner(req.params.productId)
      .call();
    res.json({ owner: currentOwner });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Run server
const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
