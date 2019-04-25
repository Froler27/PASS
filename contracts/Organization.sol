pragma solidity >=0.4.21 <0.7.0;

contract Organization{
    string name;
    address creator;
    address[] admins;
    address[] members;
    uint createdTime;   

    constructor(
        string memory _name, 
        address _creator
    ) public{
        name = _name;
        creator = _creator;
        createdTime = now;
    }

    function addAdmin(address admin) public {
        admins.push(admin);
    }

    function addMember(address member) public{
        members.push(member);
    }

    function findAdmin(address admin) public view returns(uint){
        uint i;
        for(i=0; i<admins.length; i++)
            if(admin == admins[i])
                return i;
    }

    function deleteAdmin(address admin) public{

    }
}