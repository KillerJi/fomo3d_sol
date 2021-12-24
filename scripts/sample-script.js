// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Fomo3d = await hre.ethers.getContractFactory("fomo3d");
  const fomo3d = await Fomo3d.deploy("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");

  await fomo3d.deployed();
  var v = 28;
  var r = "0x2d216c8c8e180b81b8d4733e7bfcf9eef7318209a8f883161644a3bc0e29de5d";
  var s = "0x7c77ed1b341f2aabab33f7ac5f205476e4b9e31e1d028112d23e4503885551b2";
  await fomo3d.vaultBuy(1, 1, 1, "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", 2,
    v, r, s);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
