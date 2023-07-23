//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    
    enum Gender {None, Male, Female}
    enum AnimalType {None, Fish, Cat, Dog, Rabbit, Parrot}

    address public owner;
    //To keep track of the number of animals available
    mapping(AnimalType => uint8) public animalCounts;

    //To keep track of who borrowed which animal
    mapping(address => bool) public borrower;
    mapping(address => AnimalType) public borrowedAnimal;

    //To make sure nobody can borrow wrong animals by changing age and gender
    mapping (address => Gender) public preventGenderFraud ;
    mapping (address => uint8) public preventAgeFraud ;

    //Emitting the events as per the requirement    
    event Added(AnimalType animalType, uint8 count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function add(AnimalType _animalType, uint8 _count) public onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");

        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) public {

        //To make sure only adults can engage with the Contract
        require(_age >= 18, "Only adults can borrow animals");

        //To make sure only valid animals are borrowed
        require(_animalType != AnimalType.None, "Invalid animal type");

        //To make sure there are animals left to borrow
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        //Fraud prevention Require statements
        require(_gender == Gender.Male || _gender == Gender.Female, "Gender for now can only be Male or Female");

        if(preventGenderFraud[msg.sender] != Gender.None)
        {
        require(preventGenderFraud[msg.sender] == _gender, "Invalid Gender");
        }

        if(preventAgeFraud[msg.sender] != 0)
        {
        require(preventAgeFraud[msg.sender] == _age, "Invalid Age");
        }

        
        //To make sure nobody can borrow animals twice
        require(borrower[msg.sender] == false, "Already adopted a pet");

        if(_gender == Gender.Male) {
           require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        }
         
        else if(_gender == Gender.Female) {
            if(_age<40 && _animalType == AnimalType.Cat){
                revert("Invalid animal for women under 40");
            }
        }

        animalCounts[_animalType]--;
        borrowedAnimal[msg.sender] = _animalType;
        borrower[msg.sender] = true;

        //Updating mappings to prevent Fraud
        preventGenderFraud[msg.sender] = _gender;
        preventAgeFraud[msg.sender] = _age;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(borrower[msg.sender] == true, "No borrowed pets");
        AnimalType animalType = borrowedAnimal[msg.sender];

        borrower[msg.sender] = false;
        delete borrowedAnimal[msg.sender];

        animalCounts[animalType]++;
        emit Returned(animalType);
    }
}