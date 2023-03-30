const { expect } = require("chai");
const ethers = require("hardhat").ethers;
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Treasury contract", function () {
  //uaing hardhat fixtures
  async function deployContractFixture() {
        //Deploys contract to hardhat network
        const [owner] = await ethers.getSigners();
        const ast = await ethers.getContractFactory("contracts/ast.sol:AST");
        const ausdt = await ethers.getContractFactory("aUSDT");
        const treasury = await ethers.getContractFactory("TREASURY");
        
        //deploying the contract
        const astToken = await ast.deploy(owner.address);
        const usdtToken = await ausdt.deploy(ethers.utils.parseUnits('1000000', "ether"))
        const tContract = await treasury.deploy(astToken.address, usdtToken.address, owner.address)
        // Fixtures can return anything you consider useful for your tests
         
        return {tContract, astToken, usdtToken, owner};
  }
  it("Testing if the treasury contract is connected to the AST token", async function () {
    //importing the token via the fixtures
    const {tContract, astToken,  usdtToken, owner } = await loadFixture(deployContractFixture);
    expect(await tContract.AST_ADDRESS()).to.equal(astToken.address);
  });

  it("Testing if the right usdt contract is set", async function () {
    //importing the token via the fixtures
    const {tContract, astToken,  usdtToken, owner } = await loadFixture(deployContractFixture);
    expect(await tContract.USDT()).to.equal(usdtToken.address);
  });

  it("Testing the initial price of the AST token", async function () {
    //importing the token via the fixtures
    const {tContract, astToken,  usdtToken, owner } = await loadFixture(deployContractFixture);
    expect(await tContract.getAstUsdtPrice()).to.equal(9000000);
  });

  it("Testing if 9$ would mint one AST token", async function () {
    //importing the token via the fixtures
    const {tContract, astToken,  usdtToken, owner } = await loadFixture(deployContractFixture);
    expect((await tContract.getAstUsdtEquiv(9000000)) >= 1E18).to.equal(true);
  });

  
});