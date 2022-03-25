// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

//import Open Zepplins ERC-20 interface contract and Ownable contract
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//create a ERC20 faucet contract
// Logic: people can deposit tokens to the faucet contract, and let other users to request some tokens.
contract Faucet is Ownable {

    uint256 public amountAllowed = 100 * 10 ** 18;
    address public tokenContract;
    mapping(address => bool) public requestedAddress;    
    //when deploying the token contract is given
    constructor(address _tokenContract) {
        tokenContract = _tokenContract; // set token contract
    }

    event SendToken(address indexed Receiver, uint256 indexed Amount); 
    event WithdrawToken(address indexed sender, address indexed TokenContract, uint256 indexed Amount); 
    event WithdrawETH(address indexed sender, uint256 indexed Amount); 


    //allow users to call the requestTokens function to get tokens
    function requestTokens () external {
        require(requestedAddress[_msgSender()] == false, "Can't Request Multiple Times!");
        IERC20 token = IERC20(tokenContract);
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet Empty!");

        token.transfer(_msgSender(), amountAllowed); // transfer token
        requestedAddress[_msgSender()] = true; // record requested 
        
        emit SendToken(_msgSender(), amountAllowed); // emit event
    }

    // change requested amount by owner
    function setAmount (uint256 _amount) external onlyOwner{
        amountAllowed = _amount;
    }

    // withdraw ERC20 token by owner
    function withdrawToken(address _tokenContract, uint256 _amount) public onlyOwner {
        IERC20 token = IERC20(_tokenContract);
        
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        token.transfer(_msgSender(), _amount);
        emit WithdrawToken(_msgSender(), _tokenContract, _amount);
    }

    // withdraw ETH
    function withdrawETH() public onlyOwner {
        address payable owner = payable(owner());
        uint256 amount = address(this).balance;
        owner.transfer(amount);
        emit WithdrawETH(_msgSender(), amount);
    }


}
