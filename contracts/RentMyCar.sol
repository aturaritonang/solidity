//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./Utilities.sol";

contract RentCar is Ownable, Utilities {

    uint grandTotalAmmount;

    event SmartContractSet(address indexed oldOwner, address indexed newOwner);
    event payARent(address customer, uint fee);

    struct Car {
        string name;
        uint price;
        bool available;
        address customer; 
    }

    Car[] public cars;

    constructor(){
        grandTotalAmmount = 0;
        cars.push(Car({ name: "Avanza 1", price : 1.2 ether, available : true, customer: address(0) }));
        cars.push(Car({ name: "Avanza 2", price : 1.2 ether, available : false, customer: address(0) }));
        cars.push(Car({ name: "Ayla 1", price : 1 ether, available : true, customer: address(0) }));
        cars.push(Car({ name: "Ayla 2", price : 1 ether, available : true, customer: address(0) }));
    }

    function addCar(string memory _name, uint _price, bool _available) external isOwner returns(string memory) {
        if(!carExist(_name)){
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

    function updateCar(string memory _name, uint _price, bool _available) external isOwner returns(string memory) {
        bool success = false;
        if(carExist(_name)) {
            for(uint i = 0; i < cars.length; i++){
                if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name)) && cars[i].customer == address(0)){
                    cars[i].price = _price;
                    cars[i].available = _available;
                    success = true;
                }
            }
            if(success){
                return string(abi.encodePacked(_name, ' already updated.'));
            }
        }
        return string(abi.encodePacked(_name, ' not successfully car does not exist or already rented.'));
    }

    function getBalance() public view isOwner returns(uint256){
        return grandTotalAmmount;
    }

    function withDraw() public payable isOwner{
        owner.transfer(grandTotalAmmount);
        grandTotalAmmount = 0;
    }

    function carExist(string memory _name) private view returns (bool) {
        for(uint i = 0; i < cars.length; i++){
            if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name))) {
                return true;
            }
        }
        return false;
    }

    function checkAllCar() public view isOwner returns(Car[] memory){
        return cars;
    }

    function checkACar(string memory _name) public view returns(string memory, string memory, uint){
        string memory status = "Sorry, not avaiable";
        string memory name = "No Name";
        uint price = 0;

        for(uint i = 0; i < cars.length; i++){
            if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name)) && cars[i].available) {
                // result = string(abi.encodePacked('Your car is available. Name: ', cars[i].name, ', Price: ', uint2str(cars[i].price)));
                status = "Congrats, Available";
                name = _name;
                price = cars[i].price;
            }
        }
        return (status, name, price);
    }



    function checkAvailable() public view returns(string memory){
        string memory names; 
        for(uint i = 0; i < cars.length; i++){
            string memory strAvailable;
            
            if( cars[i].available) {
                strAvailable = "Yes";
                string memory name = string(abi.encodePacked('Name: ', cars[i].name, ', Price: ', uint2str(cars[i].price), ', Available: ', strAvailable));
                // string memory name = string(abi.encodePacked('Name: ', cars[i].name, ', Available: ', strAvailable));

                if(i < cars.length - 1){
                    name = string(abi.encodePacked(name, ', '));
                }

                names = string(abi.encodePacked(names, name));
            }
        }
        return names;
    }

    function checkCarsYouRented() public view returns(string memory){
        string memory names; 
        for(uint i = 0; i < cars.length; i++){

            address yourAddres = msg.sender;
            
            if( cars[i].customer == yourAddres) {

                string memory name = string(abi.encodePacked('Name: ', cars[i].name));
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
        string memory result = "Sorry, process failed. One car one customer or underpayment.";
        if(oneCustumerOneCar() && checkPayment(_name, _days)){
            for(uint i = 0; i < cars.length; i++){
                if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name)) && cars[i].available && cars[i].customer == address(0)) {
                    uint checkOutAmount = msg.value;
                    emit payARent(msg.sender, checkOutAmount);
                    grandTotalAmmount += checkOutAmount;

                    // owner.transfer(msg.value);
                    // emit payARent(msg.sender, msg.value);
                    cars[i].available = false;
                    cars[i].customer = msg.sender;
                    result = string(abi.encodePacked('You rent a car. Name: ', cars[i].name, ', Price: ', uint2str(cars[i].price)));
                }
            }
        }
        return result;
    }

    function oneCustumerOneCar() private view returns (bool) {
        address yourAddress = msg.sender;
        for(uint i = 0; i < cars.length; i++){
            if(cars[i].customer == yourAddress){
                return false;
            }
        }
        return true;
    }

    function checkPayment(string memory _name, uint _days) private view returns (bool) {
        uint payment = msg.value;
        for(uint i = 0; i < cars.length; i++){
            if(keccak256(bytes(cars[i].name)) == keccak256(bytes(_name)) && (cars[i].price * _days) > payment) {
                return false;
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
                break;
            }
        }
        return result;
    }
}