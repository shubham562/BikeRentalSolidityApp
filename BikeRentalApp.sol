//SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.0;

contract BikeRental{

    address public owner;

    constructor(){
        owner = msg.sender;
    }
    //Add yourself as a renter

    struct Renter{
        address payable walletAddress;
        string firstName;
        string lastName;
        bool canRent;
        bool active;
        uint balance;
        uint due;
        uint start;
        uint end;
    }

    mapping(address => Renter) public renters;

    function addRenter(address payable walletAddress, string memory firstName, string memory lastName, bool canRent, bool active, uint balance, uint due, uint start, uint end) public {
        renters[walletAddress] = Renter(walletAddress, firstName, lastName, canRent, active, balance, due, start, end);
        }

    //Checkout bike

    function checkout(address walletAddress) public{
        require(renters[walletAddress].due == 0, "You have a pending balance" );
        require(renters[walletAddress].canRent == true, "You cannot Rent a bike" );
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canRent = false;
    }

    //check in a bike

    function checkIn(address walletAddress) public{
        require(renters[walletAddress].active == true, "Please checkout the bike first" );
        renters[walletAddress].active = false;
        renters[walletAddress].end = block.timestamp;
        setDueAmount(walletAddress);
        }

    //Get total duration of the bike

    function renterTimeStamp(uint start, uint end) internal pure returns(uint){
        return end - start;

    }
    function getTotalDuration(address walletAddress) public view returns(uint){
        require(renters[walletAddress].active == false, "Bike is currently checked out" );
        uint timestamp = renterTimeStamp(renters[walletAddress].start, renters[walletAddress].end);
        uint timestampInMinutes = timestamp / 60;
        return timestampInMinutes;
        // return 6;
            }

    //Get contract balance

    function balanceOf() public view returns(uint)
    {
        return address(this).balance;
    }

    // get Renter's balance

    function balanceOfRenter(address walletAddress) public view returns(uint) {
        return renters[walletAddress].balance;
    }

    //Set due amount
    
    function setDueAmount(address walletAddress) internal{
        uint timespanMinutes = getTotalDuration(walletAddress);
        uint fiveMinutesIncrement = timespanMinutes / 5;
        renters[walletAddress].due = fiveMinutesIncrement * 5000000000000000;
    }

    function canRentBike(address walletAddress) public view returns(bool){
        return renters[walletAddress].canRent;
    }

    //Desposit
    function desposit(address walletAddress) payable public{
        renters[walletAddress].balance += msg.value;
    }

    ///Make Payment
    function makePayment(address walletAddress) public payable
    {
        require(renters[walletAddress].due > 0, "You don't have a due amount");
        require(renters[walletAddress].balance > renters[walletAddress].due, "You dont have enough balance");
        renters[walletAddress].balance -= msg.value;
        renters[walletAddress].canRent = true;
        renters[walletAddress].due  = 0;
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
    }
    

}