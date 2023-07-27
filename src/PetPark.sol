//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract PetPark is Ownable {
    enum AnimalType {
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    /// @notice mapping between sheltered animals and number of animals
    mapping(AnimalType => uint256) public animalCounts;
    /// @notice mapping between borrower and their borrowed animal (set to None if did not borrow before)
    mapping(address => AnimalType) public borrowedAnimal;
    /// @notice mapping between borrower and their details
    mapping(address => BorrowerDetails) public borrowerDetails;

    struct BorrowerDetails {
        bool isRegistred;
        Gender gender;
        uint256 age;
    }

    event Added(AnimalType indexed animalType, uint256 count);
    event Borrowed(AnimalType indexed animalType);
    event Returned(AnimalType indexed animalType);

    constructor() Ownable() {}

    modifier checkBorrowCriteria(uint256 _age, Gender _gender, AnimalType _animalType) {
        require(borrowedAnimal[msg.sender] == AnimalType.None, "Already adopted a pet");
        require(_age > 0, "Age can not be zero");

        if (_gender == Gender.Male) {
            require((_animalType == AnimalType.Dog) || (_animalType == AnimalType.Fish), "Invalid animal for men");
        } else {
            if (_age < 40) {
                require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
            }
        }

        _;
    }

    modifier checkBorrowerDetails(address _borrower, uint256 _age, Gender _gender) {
        BorrowerDetails memory details = borrowerDetails[_borrower];

        if (details.isRegistered) {
            require(_age == details.age, "Invalid Age");
            require(_gender == details.gender, "Invalid Gender");

            AnimalType borrowedAnimalType = borrowedAnimal[_borrower];
            require(borrowedAnimalType == AnimalType.None, "You have already borrowed an animal. Please return it before borrowing again.");
        }

        _;
    }

    //// @notice onlyOwner would be able to call this function
    function add(AnimalType _animalType, uint256 _count) external onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");

        animalCounts[_animalType] += _count;

        emit Added(_animalType, _count);
    }

    function borrow(uint256 _age, Gender _gender, AnimalType _animalType)
        external
        checkBorrowerDetails(msg.sender, _age, _gender)
        checkBorrowCriteria(_age, _gender, _animalType)
    {
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        animalCounts[_animalType] -= 1;
        borrowedAnimal[msg.sender] = _animalType;

        borrowerDetails[msg.sender] = BorrowerDetails({isRegistred: true, gender: _gender, age: _age});

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        AnimalType borrowedAnimalType = borrowedAnimal[msg.sender];

        require(borrowedAnimalType != AnimalType.None, "No borrowed pets");

        borrowedAnimal[msg.sender] = AnimalType.None;
        animalCounts[borrowedAnimalType] += 1;

        emit Returned(borrowedAnimalType);
    }
}