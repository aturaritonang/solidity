// Price of rent base on Woi
//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./Utilities.sol";

contract RentCar is Ownable, Utilities {

    // address payable public owner;

    bool public open;

    struct Car {
        string name;
        uint price;
        bool available;
        address customer; 
    }

    enum availability { Yes, No, All }

    event payARent (address customer, uint fee);

    Car[] public cars;

    constructor(){
        // owner = msg.sender;
        open = true;
        cars.push(Car({ name: "Avanza 1", price : 1000000 wei, available : true, customer: address(0) }));
        cars.push(Car({ name: "Avanza 2", price : 1000000 wei, available : false, customer: address(0) }));
        cars.push(Car({ name: "Ayla 1", price : 900000 wei, available : true, customer: address(0) }));
        cars.push(Car({ name: "Ayla 2", price : 900000 wei, available : true, customer: address(0) }));
    }

    modifier isOpenStore {
        require(open == true, "Sorry, store is closed!");
        _;
    }

    function OpenStore() public isOwner returns(string memory) {
        open = true;
        return "Store is open.";
    }

    function CloseStore() public isOwner returns(string memory){
        open = false;
        return "Store is close.";
    }

    function addCar(string memory _name, uint _price, bool _available) external isOwner returns(string memory) {
        if(canAddNew(_name)){
            Car memory newCar = Car({
                name : _name,
                price : _price,
                available : _available,
                customer: address(0)
            });
            cars.push(newCar);
            return string(abi.encodePacked(_name, ' already added.'));
        }
        return string(abi.encodePacked(_name, ' not successfully added because it is already exist.'));
    }

    function canAddNew(string memory _name) private view returns (bool) {
        for(uint i = 0; i < cars.length; i++){          
            if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name))) {
                return false;
            }
        }
        return true;
    }

    function checkAllCar() public view isOpenStore isOwner returns(string memory){
        string memory names; 
        for(uint i = 0; i < cars.length; i++){
            string memory strAvailable;
            
            if( cars[i].available ) {
                strAvailable = 'Yes';
            } else {
                strAvailable = 'No';
            }

            string memory name = string(abi.encodePacked('Name: ', cars[i].name, ', Price: ', uint2str(cars[i].price), ' Wei, Available: ', strAvailable, ', Customer: ', toAsciiString(cars[i].customer)));

            if(i < cars.length - 1){
                name = string(abi.encodePacked(name, ', '));
            }

            names = string(abi.encodePacked(names, name));
        }
        return names;
    }

    function checkACar(string memory _name) public view isOpenStore returns(string memory){
        string memory result = "Car not available.";
        for(uint i = 0; i < cars.length; i++){
                if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name)) && cars[i].available) {
                    result = string(abi.encodePacked('Your car is available. Name: ', cars[i].name, ', Price: ', uint2str(cars[i].price), ' Wei'));
                }
            }
        return result;
    }

    function checkAvailable() public view returns(string memory){
        string memory names; 
        for(uint i = 0; i < cars.length; i++){
            string memory strAvailable;
            
            if( cars[i].available ) {

                string memory name = string(abi.encodePacked('Name: ', cars[i].name, ', Price: ', uint2str(cars[i].price), ' Wei, Available: ', strAvailable));
                // string memory name = string(abi.encodePacked('Name: ', cars[i].name, ', Available: ', strAvailable));

                if(i < cars.length - 1){
                    name = string(abi.encodePacked(name, ', '));
                }

                names = string(abi.encodePacked(names, name));
            }
        }
        return names;
    }

    function rentACar(string memory _name, uint _days) payable external isNotOwner returns(string memory){
        string memory result = "Sorry, process failed. One car one customer or payment below of price.";
        if(validationFirst(_name, _days)){
            for(uint i = 0; i < cars.length; i++){
                if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name)) && cars[i].available && cars[i].customer == address(0)) {
                    owner.transfer(msg.value);
                    emit payARent(msg.sender, msg.value);
                    cars[i].available = false;
                    cars[i].customer = msg.sender;
                    result = string(abi.encodePacked('You rent a car. Name: ', cars[i].name, ', Price: ', uint2str(cars[i].price), ' Wei'));
                }
            }
        }
        return result;
    }

    function validationFirst(string memory _name, uint _days) private view returns (bool) {
        for(uint i = 0; i < cars.length; i++){
            if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name))) {
                if(cars[i].customer == msg.sender || (cars[i].price * _days) < msg.value){
                    return false;
                }
            }
        }
        return true;
    }

    function returnACar(string memory _name) public isNotOwner returns(string memory){
        string memory result = "You are not a borrower this car.";
        for(uint i = 0; i < cars.length; i++){
            if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name)) && cars[i].customer == msg.sender) {
                cars[i].available = true;
                cars[i].customer = address(0);
                result = "Thank you.";
            }
        }
        return result;
    }
}