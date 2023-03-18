// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./owner.sol";

contract AST is ERC20 , Owner {

    address private AUTHORIZED; //contains the address authorized to mint tokens

    constructor(address _owner) ERC20("AST Token", "AST") {
        owner = _owner;
    }
    /*
        Mints token to the specified address
        Note, only authorized address is allowed to mint AST tokens
        As specified in the tokenomics, only the Treasury contract is allowed to mint new tokens
    */
    function mint(address to, uint256 amount) public returns(bool) {
        require(AUTHORIZED != address(0), "No address has been authorized to mint tokens");
        require(msg.sender == AUTHORIZED, "Not authorized to mint tokens");
        _mint(to, amount);
        return true;
    }

    /*
        This function authorizes a particular address to mint tokens
        It can only be called by the admin of this smart contract
        and it should be called authorize the treasury contratc to mint AST tokens
    */
    function authorized(address _authorizeAddress) isOwner external returns(bool){
        AUTHORIZED = _authorizeAddress;
        return true;
    }
   
}