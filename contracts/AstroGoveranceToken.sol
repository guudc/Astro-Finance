// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AGT is ERC20 , Ownable {
    constructor(uint256 initialSupply) ERC20("Astro Goverance Token", "AGT") {
        _mint(msg.sender, initialSupply);
    }
    //Mint tokens to the owner address
    function mint(uint256 amount) external onlyOwner returns(bool) {
        _mint(msg.sender, amount);
        return true;
    }
    //Burns token from the sender address
    function burn(uint256 amount) external onlyOwner returns(bool) {
        _burn(msg.sender, amount);
        return true;
    }

}