/*
    The Astro finance Treasury contract
    it handles the minting of the AST token
    author: AstroFinance Dev
    owner: Astro Finance
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

//the import statements
import "./owner.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Bancor.sol";


//declare the AST token interface
interface AST {
    function mint(address to, uint256 amount) external returns (bool);
}
//Begining of contract
contract ASTRO_TREASURY is Owner, BancorFormula {
    //variables declaration
    IERC20 private AST_TOKEN; //exposes all the erc20 token functions
    AST private AST_TOKEN_MINT; //exposes the AST internal mint function
    address public AST_ADDRESS; //exposes the AST token address
    address public USDT; //exposes the usdt address being used
    address public STRATEGY_DEPLOYER; //exposes the strategy deployer contract address

    //constants
    uint256 public RESERVE_BALANCE = 65 * 10**17; //Reserve usdt backing up the AST token. By default its 6.5USDT. We are using  18 decimal digits
    uint256 public RESERVE_RATIO = 800000; //using a default value of 80%
    
    //events
    event Deposit(uint256 amount, address receiver, uint256 ast_minted);
    /*
        Initialize the Treasury contract with
        the AST token address
    */
    constructor (address _ast, address _usdt, address _owner) {
        AST_TOKEN = IERC20(_ast);
        AST_TOKEN_MINT = AST(_ast);
        AST_ADDRESS = _ast; 
        USDT = _usdt;
        owner = _owner;
        //verify that the provided AST address is valid
        require(AST_TOKEN.balanceOf(address(this)) == 0, "Invalid AST token address given");
        require(IERC20(_usdt).balanceOf(address(this)) == 0, "Invalid USDT token address given");
    }
    /*
        mints new AST token with the price determined by
        the neg exp. bonding curve. The base token used is USDT
        @params amount - the amount of USDT token to be deposited
        @params receiver - the address in which the token would be minted to
    */
    function deposit(uint256 amount, address receiver) external returns(bool) {
        //get the current price based on the bonding curve
        uint256 ast_amount = getAstUsdtEquiv(amount);
        require(IERC20(USDT).balanceOf(msg.sender) >= amount, "Insufficient USDT to purchase AST");
        require(STRATEGY_DEPLOYER != address(0), "No strategy deployer contract address set");
        //transfer the USDT from the buyer to the treasury contract
        IERC20(USDT).transferFrom(msg.sender, STRATEGY_DEPLOYER, amount);
        //mint new tokens to the specified receiver address
        AST_TOKEN_MINT.mint(receiver, ast_amount);
        RESERVE_BALANCE += cUsdtEth(amount);
        emit Deposit(amount, receiver, ast_amount);
        return true;
    }

    //Utilities functions
    /*
        Returns the current price of the AST token in terms of usdt
    */
    function getAstUsdtPrice() public view returns(uint) {
        uint price = 9E6;
        for(uint i = 1E6;i<=100E6; i += 1E6) {
            if(getAstUsdtEquiv(i) >= 1E18) {
                price = i;
                break;
            }
        }
         return price;
    }
   
    /*
        Returns the AST/USDT equivalent based on the bonding curve
        @params amount - the amount of usdt
    */
    function getAstUsdtEquiv(uint256 amount) public view returns(uint) {
         uint256 value =  cUsdtEth(amount); 
         uint256 totalSupply = IERC20(AST_ADDRESS).totalSupply();
         if(totalSupply <= 0) {
             totalSupply = 1 * 10**18;
         }
         uint256 equiv =  purchaseTargetAmount(
                totalSupply,
                RESERVE_BALANCE,
                uint32(RESERVE_RATIO),
                value
            );
        return equiv;  
    }
 
    //converts usdt 6 decimals to ethereum 18 decimals
    function cUsdtEth(uint256 amount) private pure returns (uint) {
         return (amount * 1e12);
    }
    //converts usdt ethereum 18 decimals to usdt 6 decimals
    function cEthUsdt(uint256 amount) private pure returns (uint) {
         return (amount / 1e12);
    }
    //sets the strategy deployer contract address
    function setStrategyDeployerAddress(address _deployer) external isOwner {
        STRATEGY_DEPLOYER = _deployer;
    }
    //returns the total USDT deposited
    function totalUsdtDeposited() external view returns (uint) {
         return RESERVE_BALANCE - (65 * 10**17);
    }

}
