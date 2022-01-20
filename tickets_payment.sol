// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";
import "./ERC20.sol";

contract Tickets{
    //Token contract instance
    ERC20Basic private token;

    //Declarations
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


}