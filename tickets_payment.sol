// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";
import "./ERC20.sol";

contract Tickets{

    using SafeMath for uint;

    //------------------------------ INITIAL DECLARATIONS ----------------------------------------
    //Token contract instance
    ERC20Basic private token;

    //Contract owner address
    address payable public owner;

    //Constructor
    constructor() public{
        token = new ERC20Basic(10000000);
        owner = msg.sender;
    }

    //Customers
    struct customer{
        uint tokens_bought;
        string[] attractions_visited;
    }

    //Customers registration
    mapping(address => customer) public Customers;

    //------------------------------ TOKENS MANAGEMENT -------------------------------------------
    //Get token price
    function GetTokenPrice(uint _numTokens) internal pure returns(uint){
        //Convert tokens to eth
        return _numTokens.mul(1 ether);
    }

    //Buy tokens
    function BuyTokens(uint _numTokens) public payable{
        //get price
        uint price = GetTokenPrice(_numTokens);
        //check if the amount of eth in payment is enough
        require(msg.value >= price, "Not enough ETH to buy that quantity of tokens");
        //check change
        uint returnValue = msg.value.sub(price);
        msg.sender.transfer(returnValue);
        //get available tokens
        uint balance = balanceOf();
        require(_numTokens <= balance, "Buy less tokens");
        //transfer tokens to customer
        token.transfer(msg.sender, _numTokens);
        //store data
        Customers[msg.sender].tokens_bought = _numTokens;
    }

    //Get amount of available tokens
    function balanceOf() public view returns(uint){
        return token.balanceOf(address(this));
    }

}