// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IWStETH} from "./interface/IWStETH.sol";

// a utility class with variables we will want to access
abstract contract YieldUtils {
    address public PT;
    address public YT;
    address public constant wstETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address public constant stETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    uint256 expiryTime;

    function isExpired() public view returns (bool) {
        return (block.timestamp > expiryTime);
    }

    // amount of stETH for 1 wstETH
    function exchangeRate() public view returns (uint256) {
        return IWStETH(wstETH).stEthPerToken();
    }
}
