// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { expect } = require("chai");
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const [owner, addr1, addr2] = await hre.ethers.getSigners();
  console.log(owner.address, addr1.address, addr2.address);

  // We get the contract to deploy
  const Fomo3d = await hre.ethers.getContractFactory("fomo3d");
  const fomo3d = await Fomo3d.deploy("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
  expect(await fomo3d.owner()).to.equal(owner.address);
  expect(await fomo3d.key_init_price()).to.equal((0.01 * 1e18).toString());
  expect(await fomo3d.key_final_price()).to.equal((0.01 * 1e18).toString());
  expect(await fomo3d.key_increasing_price()).to.equal((0.00002 * 1e18).toString());
  expect(await fomo3d.rounds()).to.equal(1);
  console.log("2222222222222222");
  expect(await fomo3d.start_time(1)).to.equal(0);
  expect(await fomo3d.end_time(1)).to.equal(0);

  await fomo3d.connect(owner).setActionTime(1640677187);
  expect(await fomo3d.start_time(1)).to.equal(1640677187);
  expect(await fomo3d.end_time(1)).to.equal(1640763587);
  // await fomo3d.deployed();

  console.log("2222222222222222");
  var v = 27;
  var r = "0x827ce6a10e22628df4fd084bab61644381af9b075541059ca3f1b1ab5ab2335d";
  var s = "0x613256e8a35857366f3d8dd36681167dab861cfe7868a5b0fe7b25827148e494";
  var buy_num = 3;
  var team = 2;
  var rounds = 1;
  await fomo3d.connect(owner).vaultBuy(buy_num, team, rounds, owner.address, 2,
    v, r, s, { value: ethers.utils.parseEther("0.03006") });
  expect(await fomo3d.key_final_price()).to.equal((0.01006 * 1e18).toString());
  // expect(await fomo3d.end_time(1)).to.equal(1640759306);
  // const balance = await fomo3d.balanceOf(owner.address);
  // console.log(balance);
  console.log("2222222222222222");
  var v = 28;
  var r = "0x7a8a83b72ce52d4207fec6e6f85428bf8740d79713b6f439579eea2fbac0e1e8";
  var s = "0x226ab2e1d97eb892bd215e74b90ac0e5770fad6aa4914fab77a694ae66a1c4cb";
  var claim_num = (0.03006 * 10 ** 18).toString();
  await fomo3d.connect(owner).claim(owner.address, claim_num, 2,
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
