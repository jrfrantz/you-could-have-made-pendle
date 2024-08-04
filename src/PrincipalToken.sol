// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {YieldUtils} from "./YieldUtils.sol";
import {YieldToken} from "./YieldToken.sol";

contract PrincipalToken is ERC20, YieldUtils {
    constructor() ERC20("PrincipalToken", "PT") {}

    // 1 wstETH = 1 Principal Entitlement for 1stETH...
    function mintPrincipalAndYield(uint256 amount) public {
        IERC20(wstETH).transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
        YieldToken(YT).mint(msg.sender, amount);
    }
    // redeem your stETH principal back (but no yield!)

    function redeemAtExpiry() public {
        require(isExpired(), "cant redeem until expiry");
        // x wstETH * exchangeRate() = y stETH
        uint256 amountStEthOwed = balanceOf(msg.sender);
        uint256 amountToTransfer = amountStEthOwed / exchangeRate();
        // for simplicity, transfer the stETH equivalent back in wstETH
        IERC20(wstETH).transferFrom(address(this), msg.sender, amountToTransfer);
        _burn(msg.sender, amountToTransfer);
    }
}
