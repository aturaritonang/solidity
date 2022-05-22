//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;
// import "@openzeppelin/contracts/utils/Strings.sol";

contract RentCar {

    address payable public owner;

    bool public open;

    struct Car {
        string name;
        string price;
        bool available;
        address customer; 
    }

    enum availability { Yes, No, All }

    Car[] public cars;

    constructor(){
        owner = msg.sender;
        open = true;
        cars.push(Car({ name: "Car 1", price : "1000000", available : true, customer: address(0) }));
        cars.push(Car({ name: "Car 2", price : "2000000", available : false, customer: address(0) }));
        cars.push(Car({ name: "Car 3", price : "1500000", available : true, customer: address(0) }));
        cars.push(Car({ name: "Car 4", price : "2000000", available : true, customer: address(0) }));
    }

    modifier isOwner {
        require(owner == msg.sender, "You are not owner");
        _;
    }

    modifier isNotOwner {
        require(owner != msg.sender, "You are owner");
        _;
    }

    modifier isOpenStore {
        require(open == true, "Sorry, store is closed!");
        _;
    }

    function OpenStore() public isOwner returns(string memory) {
        open = true;
        return "Store is open";
    }

    function CloseStore() public isOwner returns(string memory){
        open = false;
        return "Store is close";
    }

    function addCar(string memory _name, string memory _price, bool _available) external isOwner {
        Car memory newCar = Car({
            name : _name,
            price : _price,
            available : _available,
            customer: address(0)
        });
        cars.push(newCar);
    }

    function checkAllCar() public view isOpenStore returns(string memory){
        string memory names; 
        for(uint i = 0; i < cars.length; i++){
            string memory strAvailable;
            if( cars[i].available ) {
                strAvailable = 'Yes';
            } else {
                strAvailable = 'No';
            }
            string memory name = string(abi.encodePacked('Name: ', cars[i].name, ', Price: ', cars[i].price, ' Wei, Available: ', strAvailable));
            if(i < cars.length - 1){
                name = string(abi.encodePacked(name, ', '));
            }
            names = string(abi.encodePacked(names, name));
        }
        return names;
    }

    function checkAvailable(string memory _carName) external isNotOwner {
    }

}