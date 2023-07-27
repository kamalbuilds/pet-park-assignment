//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {

  address public owner;

  enum AnimalType {
    None,
    Fish,
    Cat,
    Dog,
    Rabbit,
    Parrot
  }

  enum Gender {
    None,
    Male,
    Female
  }

  struct Borrower {
    uint age;
    Gender gender;
    AnimalType animalType;
  }

  mapping(AnimalType => uint) public animalCounts;

  mapping(address => Borrower) public addrToBorrower;

  event Added(AnimalType animalType, uint animalCount);

  event Borrowed(AnimalType animalType);

  event Returned(AnimalType animalType);

  constructor() {
      owner = msg.sender;
   }

  modifier onlyOwner {
      require(msg.sender == owner, "Not owner");
      _;
   }

  function add(AnimalType animalType, uint animalCount) public onlyOwner {
    require(animalType != AnimalType.None, "Invalid animal");

     animalCounts[animalType] += animalCount;

     emit Added(animalType, animalCount);
  }

function borrow(uint age, Gender gender, AnimalType animalType) public {
    require(animalType != AnimalType.None, "Invalid animal type");
    
    require(age > 0, "Invalid age");

    require(animalCounts[animalType] > 0, "Selected animal not available");

    if (gender == Gender.Male) {
      require (animalType == AnimalType.Dog || animalType == AnimalType.Fish, "Invalid animal for men");
    }

    if (gender == Gender.Female && age < 40) {
      require (animalType != AnimalType.Cat, "Invalid animal for women under 40");
    }

    Borrower storage borrower = addrToBorrower[msg.sender];

    if (borrower.age != 0) {
      require(borrower.age == age, "Invalid Age");
    }

    if (borrower.gender != Gender.None) {
      require(borrower.gender == gender, "Invalid Gender");
    }

    require(borrower.animalType == AnimalType.None, "Already adopted a pet");

    animalCounts[animalType] = animalCounts[animalType] - 1;

    borrower.age = age;
    borrower.gender = gender;
    borrower.animalType = animalType;

    addrToBorrower[msg.sender] = borrower;

    emit Borrowed(animalType);
  }


  function giveBackAnimal() public {
    Borrower storage borrower = addrToBorrower[msg.sender];

    require(borrower.animalType != AnimalType.None, "No borrowed pets");

    animalCounts[borrower.animalType] += 1;

    borrower.animalType = AnimalType.None;

    emit Returned(borrower.animalType);
  }
}
