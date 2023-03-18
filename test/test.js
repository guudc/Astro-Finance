const { expect } = require("chai");
const ethers = require("hardhat").ethers;
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("AST Token contract", function () {
  //uaing hardhat fixtures
  async function deployTokenFixture() {
        //Deploys contract to hardhat network
        const [owner] = await ethers.getSigners();
        const ast = await ethers.getContractFactory("AST");
        //deploying the contract
        const hardhatToken = await ast.deploy(owner.address);
        // Fixtures can return anything you consider useful for your tests
        return {hardhatToken, owner};
  }
  //testing the token name
  it("Testing the name of the token", async function () {
    //importing the token via the fixtures
    const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
    expect(await hardhatToken.name()).to.equal('AST Token');
  });
  //testing the token symbol
  it("Testing the symbol of the token", async function () {
    //importing the token via the fixtures
    const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
    expect(await hardhatToken.symbol()).to.equal('AST');
  });
  //testing the token initial supply
  it("Total supply should be zero", async function () {
    //importing the token via the fixtures
    const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
    expect(await hardhatToken.totalSupply()).to.equal(0);
  });
  //testing the set treasury address  
  it("Testing the mint function after setting the treasury address", async function () {
    //importing the token via the fixtures
    const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
    await hardhatToken.authorized(owner.address)
    await hardhatToken.mint(owner.address, 10000)
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(10000);
  });
});