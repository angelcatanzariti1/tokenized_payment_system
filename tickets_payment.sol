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
    event enjoy_attraction(string, uint, address);
    event new_attraction(string, uint);
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

    //------------------------------ ATTRACTIONS MANAGEMENT --------------------------------------
    //Create new attraction. Resricted to owner
    function NewAttraction(string memory _attractionName, uint _price) public OnlyOwner(msg.sender){
        //Creation
        MappingAttractions[_attractionName] = attraction(_attractionName, _price, true); //default status: true
        //Storing names
        Attractions.push(_attractionName);
        //Emit event
        emit new_attraction(_attractionName, _price);
    }

    //Delete attraction. Resricted to owner
    function DeleteAttraction(string memory _attractionName) public OnlyOwner(msg.sender){
        require(MappingAttractions[_attractionName].status_attraction == false, "The attraction is already down or it doesn't exist");
        //Set status to false
        MappingAttractions[_attractionName].status_attraction = false;
        //Emit event
        emit delete_attraction(_attractionName);
    }

    //View attractions
    function AvailableAttractions() public view returns(string[] memory){
        return Attractions;
    }

    //Pay for an attraction
    function UseAttraction(string memory _attractionName) public{
        //price (in tokens)
        uint attraction_token_price = MappingAttractions[_attractionName].price_attranction;
        //check status
        require(MappingAttractions[_attractionName].status_attraction == true, "Attraction currently not available");
        //check if customer has enough tokens
        require(attraction_token_price <= MyTokens(),"You need tu buy more tokens to use this attraction");
        //transfer, using custom function from ERC20.sol to allow customer to pay for attraction
        token.transfer_custom(msg.sender, address(this), attraction_token_price);
        //save attraction use in history
        AttractionsHistory[msg.sender].push(_attractionName);
        //emit event
        emit enjoy_attraction(_attractionName, attraction_token_price, msg.sender);
    }

    //View attractions used by customers
    function History() public view returns(string[] memory){
        return(AttractionsHistory[msg.sender]);
    }

    //Tokens refund
    function RefundTokens(uint _numTokens) public payable{
        //check for positive number
        require(_numTokens > 0, "Number of tokens must be greater than 0");
        //check for availability of tokens
        require(_numTokens <= MyTokens(), "Not enough tokens");
        //customer gives back tokens
        token.transfer_custom(msg.sender, address(this), _numTokens);
        //refund ether
        msg.sender.transfer(GetTokenPrice(_numTokens));
    } 


}