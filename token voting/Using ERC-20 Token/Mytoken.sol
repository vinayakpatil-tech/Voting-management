// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 100000 * 10 ** decimals()); // 100,000 tokens to your address
    }
}
