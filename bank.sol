pragma solidity 0.7.0;

import "bank_interface.sol";

contract Bank is IBank{
    function deposit(address token, uint256 amount) override payable external returns (bool) {
        return true;
    }
    
    function withdraw(address token, uint256 amount) override external returns (uint256) {
        return 0;
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
        return 0;
    }
}