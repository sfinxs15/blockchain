//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    address payable public immutable owner;
    bool private _isSaleAvailable;
    uint256 public constant MAX_SUPPLY = 1e24;
    uint256 public constant TOKEN_PER_ETHER = 1000;

    event TokenPurchased(address);

    constructor() ERC20("MyToken", "MT") {
        owner = payable(msg.sender);
        _isSaleAvailable = true;
    }

    function buyToken() public payable {
        require(_isSaleAvailable, "Token sales closed!");
        require(msg.value == 1 ether, "Not enough ether!");

        uint256 currentSupply = totalSupply();
        if (currentSupply == MAX_SUPPLY) {
            _isSaleAvailable = false;
        }

        // tokens are set according to ether decimal places
        uint256 amount = TOKEN_PER_ETHER * (10 ** decimals());
        _mint(msg.sender, amount);

        emit TokenPurchased(msg.sender);
    }

    function withdraw(address payable to) public payable {
        require(to != address(0), "Invalid address!");
        require(msg.sender == owner, "Not contract owner!");
        require(totalSupply() == 0, "Tokens are still in circulation!");
        uint256 amount = address(this).balance;
        to.transfer(amount);
    }
}
