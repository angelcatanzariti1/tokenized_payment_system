// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";
import "./ERC20.sol";

contract Tickets{

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
    //Set token price
    function TokenPrice(uint _numTokens) internal pure returns(uint){
        //Convert tokens to eth
        return _numTokens*(1 ether);
    }



}