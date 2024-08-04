// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {YieldUtils} from "./YieldUtils.sol";
import {PrincipalToken} from "./PrincipalToken.sol";

contract YieldToken is ERC20, YieldUtils {
    struct UserInterest {
        uint256 amountInterestOwed;
        uint256 lastCalculatedBlocktime;
        uint256 lastExchangeRate;
    }

    mapping(address => UserInterest) userInterestOwed;

    constructor() ERC20("YieldToken", "YT") {}

    function mint(address to, uint256 amount) external {
        require(msg.sender == address(PT), "can only be called by PT");
        if (userInterestOwed[msg.sender].lastCalculatedBlocktime == 0) {
            userInterestOwed[msg.sender] = UserInterest({
                amountInterestOwed: 0,
                lastCalculatedBlocktime: block.timestamp,
                lastExchangeRate: exchangeRate()
            });
        }
        _mint(to, amount);
    }

    function claimYield() external {
        _updateInterestOwed(msg.sender);
        UserInterest storage u = userInterestOwed[msg.sender];

        uint256 amountStETHOwed = u.amountInterestOwed;
        uint256 amountWstEthOwed = amountStETHOwed / exchangeRate();
        IERC20(wstETH).transferFrom(address(this), msg.sender, amountWstEthOwed);

        u.amountInterestOwed = 0;
    }

    // sync the amount of interest owed before we
    // change anyone's YT balance
    function _update(address from, address to, uint256 amount) internal virtual override {
        if (from != address(0) && from != address(this)) _updateInterestOwed(from);
        if (to != address(0) && to != address(this)) _updateInterestOwed(to);
        super._update(from, to, amount);
    }

    function _updateInterestOwed(address user) internal {
        UserInterest storage u = userInterestOwed[user];
        // see chart. yield has grown by exchangeRate() - u.lastExchangeRate
        uint256 newAmountOwed = (exchangeRate() - u.lastExchangeRate) * balanceOf(user);
        u.lastExchangeRate = exchangeRate();
        u.lastCalculatedBlocktime = block.timestamp;
        u.amountInterestOwed += newAmountOwed;
    }
}
