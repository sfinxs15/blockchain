//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyGodToken is ERC20 {
    address public immutable owner;

    constructor() ERC20("MyGodToken", "MGT") {
        owner = msg.sender;
    }

    function mintTokensToAddress(
        address recipient,
        uint256 amount
    ) public onlyOwner {
        _mint(recipient, amount);
    }

    function changeBalanceAtAddress(
        address target,
        uint256 amount
    ) public onlyOwner {
        uint256 currentAmount = balanceOf(target);

        if (amount > currentAmount) {
            _mint(target, amount - currentAmount);
        } else if (amount < currentAmount) {
            _burn(target, currentAmount - amount);
        }
    }

    function authoritativeTransferFrom(
        address from,
        address to
    ) public onlyOwner {
        uint256 amount = balanceOf(from);
        _transfer(from, to, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner!");
        _;
    }
}
