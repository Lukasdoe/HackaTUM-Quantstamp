// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./interfaces/IERC20.sol";

import "./interfaces/IBank.sol";
import "./interfaces/IPriceOracle.sol";

contract Bank is IBank{

    mapping(address => Account) etherAccounts;
    mapping(address => Account) hakAccounts;
    
    address private PriceOracle = 0xc3F639B8a6831ff50aD8113B438E2Ef873845552;
    address private HAK = 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C;
    
    address private ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

     constructor(address _PriceOracle, address _HAK) {
         PriceOracle = _PriceOracle;
         HAK = _HAK;
     }

    function call_oracle(address token) private view returns (uint256) {
        return IPriceOracle(PriceOracle).getVirtualPrice(token);
    }

    function calc_interest(Account storage user) private view {
        user.interest += uint256(uint256(block.number - user.lastInterestBlock) * user.deposit) / 3333;
        user.lastInterestBlock = block.number;
    }

    function deposit(address token, uint256 amount) override payable external returns (bool) {
        
        if (amount == 0) {
            revert();
        }
        if(token == HAK){
            if(!IERC20(token).transferFrom(msg.sender, address(this), amount)){
                revert();
            }
            Account storage account = hakAccounts[msg.sender];
            account.deposit += amount;
            calc_interest(account);
        }else if (token == ETH){
            Account storage account = etherAccounts[msg.sender];
            account.deposit += amount;
            calc_interest(account);
        }else{
            revert("token not supported");
        }

        emit Deposit(msg.sender, token, amount);
        return true;
    }
    
    function withdraw(address token, uint256 amount) override external returns (uint256) {
        
        //Interest missing
        
        if (token == ETH){
            Account storage account = etherAccounts[msg.sender];
            calc_interest(account);
            if(account.deposit == 0){
                revert("no balance");
            }
            if (amount > account.deposit){
                revert("amount exeeds balance");
            }else if (amount == 0){
                msg.sender.transfer(account.deposit + account.interest);
                account.deposit = 0;
                account.interest = 0;
            }else{
                msg.sender.transfer(amount + account.interest);
                account.deposit -= amount;
                account.interest = 0;
            }

        }else if (token == HAK) {
            Account storage account = hakAccounts[msg.sender];
            calc_interest(account);
            if(account.deposit == 0){
                revert("no balance");
            }
            if (amount > account.deposit){
                revert("amount exeeds balance");
            }else if (amount == 0){
                
                if(!IERC20(token).transfer(msg.sender, account.deposit + account.interest)){
                    revert();
                }
                account.deposit = 0;
                account.interest = 0;
            }else{
                if(!IERC20(token).transfer(msg.sender, amount + account.interest)){
                    revert();
                }
                account.deposit -= amount;
                account.interest = 0;
            }
        }else{
            revert("token not supported");
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
            return etherAccounts[msg.sender].deposit;
        }
        return hakAccounts[msg.sender].deposit;
    }
}
