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

    //Modifiers
    modifier OnlyOwner(address _address){
        require(_address == owner, "Forbidden");
        _;
    }

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
        Customers[msg.sender].tokens_bought += _numTokens;
    }

    //Get amount of available tokens
    function balanceOf() public view returns(uint){
        return token.balanceOf(address(this));
    }

    //Get how many tokens a customer has
    function MyTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

    //Increase total tokens
    function MakeTokens(uint _numToken) public OnlyOwner(msg.sender){
        token.increaseTotalSupply(_numToken);
    }

    //------------------------------ GENERAL MANAGEMENT -------------------------------------------
    //Events
    event enjoy_attraction(string);
    event new_attraction(string);
    event delete_attraction(string);

    //Attractions name => data struct
    struct attraction{
        string name_attraction;
        uint price_attranction;
        bool status_attraction;
    }

    mapping(string => attraction) public MappingAttractions;

    //Array to store attractions' names
    string[] Attractions;

    //Mapping customer => attraction history
    mapping(address => string[]) AttractionsHistory;

    


}