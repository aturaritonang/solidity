//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;

contract RentCar {
    address payable public owner;

    Car[] public cars;

    constructor(){
        cars.push(Car({ name: "Car 1", price : 1, available : true }));
        cars.push(Car({ name: "Car 2", price : 2, available : true }));
        cars.push(Car({ name: "Car 3", price : 3, available : true }));
    }

    struct Car {
        string name;
        uint price;
        bool available;
    }

    modifier isOwner {
        require(owner == msg.sender, "You are not owner");
        _;
    }

    modifier isNotOwner {
        require(owner != msg.sender, "You are owner");
        _;
    }

    function addCar(string memory _name, uint _price, bool _available) external isOwner {
        Car memory newCar = Car({
            name : _name,
            price : _price,
            available : _available
        });
        cars.push(newCar);
    }

    function checkAllCar() external isOwner {
        
    }

    function checkAvailable(string memory _carName) external isNotOwner {
    }

}