// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "bank_interface.sol";
import "oracle.sol";

contract Bank is IBank{

    mapping(address => Account) userAccounts;
    address PriceOracle = 0xc3F639B8a6831ff50aD8113B438E2Ef873845552;
    address HAK = 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C;
    address ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address _PriceOracle, address _HAK) {
        PriceOracle = _PriceOracle;
        HAK = _HAK;
    }

    function call_oracle(address token) private view returns (uint256) {
        return IPriceOracle(PriceOracle).getVirtualPrice(token);
    }

    function calc_interest(Account memory user) private view {
        user.interest += uint256(uint256(block.number - user.lastInterestBlock) * uint256((0.03 / 100) * 100000)) / 100000 * user.deposit;
        user.lastInterestBlock = block.number;
    }

    function deposit(address token, uint256 amount) override payable external returns (bool) {
        if (amount == 0) {
            return false;
        }
        if (token == HAK) {
            amount *= call_oracle(HAK);
        }
        else if (token != ETH) {
            return false;
        }
        userAccounts[msg.sender].deposit += amount;
        calc_interest(userAccounts[msg.sender]);

        emit Deposit(msg.sender, token, amount);
        return true;
    }
    
    function withdraw(address token, uint256 amount) override external returns (uint256) {
        if (token == HAK) {
            amount *= call_oracle(HAK);
        }
        else if (token != ETH) {
            return 0;
        }

        if (amount > userAccounts[msg.sender].deposit) {
            return 0;
        }
        else if (amount == 0) {
            amount = userAccounts[msg.sender].deposit;
        }

        calc_interest(userAccounts[msg.sender]);
        userAccounts[msg.sender].deposit -= amount;

        amount += userAccounts[msg.sender].interest;
        userAccounts[msg.sender].interest = 0;
        
        if (token == HAK) {
            amount /= call_oracle(HAK);
        }
        emit Withdraw(msg.sender, token, amount);
        return amount;
    }
    
    function borrow(address token, uint256 amount) override external returns (uint256) {
        return 0;
    }
    
    function repay(address token, uint256 amount) override payable external returns (uint256) {
        return 0;
    }
    
    function liquidate(address token, address account) override payable external returns (bool) {
        return true;
    }
    
    function getCollateralRatio(address token, address account) override view external returns (uint256){
        return 0;
    }
    
    function getBalance(address token) override view external returns (uint256){
        // ether = ETH
        if (token == ETH) {
            return userAccounts[msg.sender].deposit;
        }
        return userAccounts[msg.sender].deposit / call_oracle(token);
    }
}
