const { ethers } = require("hardhat");

async function main() {
  const ownerAddress = "0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f";
  const CropInsurance = await ethers.getContractFactory("CropInsurance");
  const cropInsurance = await CropInsurance.deploy(ownerAddress);

  console.log("Deploying CropInsurance contract...");

  // Wait for the contract to be deployed and mined
  const deployedContract = await new Promise((resolve, reject) => {
    cropInsurance.deployTransaction.on("receipt", (receipt) => {
      console.log("CropInsurance deployed to:", receipt.contractAddress);
      resolve(receipt.contractAddress);
    });

    cropInsurance.deployTransaction.on("error", (error) => {
      reject(error);
    });
  });

  // You can do further processing with the deployed contract if needed
  console.log("CropInsurance contract deployed successfully.");

  // Additional processing...
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error deploying CropInsurance contract:", error);
    process.exit(1);
});
