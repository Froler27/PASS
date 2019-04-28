pragma solidity >=0.4.21 <0.7.0;

import "./Organization.sol";

contract User{
    string realName;
    string IDCardNum;
    address myself;
    uint registerTime; 

    string[] ownOrgs;          // 用户创建的组织
    string[] adminOrgs;        // 用户管理的组织
    string[] memberOrgs;       // 用户加入的组织


    constructor() public{
        myself = msg.sender;
        registerTime = now;
    }

    modifier onlyMyself{
        require(
            msg.sender == myself,
            "Only the user himself/herself  can use this function!"
        );
        _;
    }

    function strcmp(string memory _str1, string memory _str2) public pure returns(bool) {
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

    function getName() public view returns(string memory){
        return realName;
    }


    function findOwnOrg(string memory ownOrg) public view returns(uint){
        uint i;
        for(i=0; i<ownOrgs.length; i++)
            if(strcmp(ownOrg, ownOrgs[i]))
                return i;
        return i;
    }

    function findAdminOrg(string memory adminOrg) public view returns(uint){
        uint i;
        for(i=0; i<adminOrgs.length; i++)
            if(strcmp(adminOrg, adminOrgs[i]))
                return i;
        return i;
    }

    function findMemberOrg(string memory memberOrg) public view returns(uint){
        uint i;
        for(i=0; i<memberOrgs.length; i++)
            if(strcmp(memberOrg, memberOrgs[i]))
                return i;
        return i;
    }
    
    //---------------------------------------------------

    function addOwnOrg(string memory ownOrg) public {
        ownOrgs.push(ownOrg);
    }

    function addAdminOrg(string memory _orgName) public {
        adminOrgs.push(_orgName);
    }

    function addMemberOrg(string memory _orgName) public {
        memberOrgs.push(_orgName);
    }

    //-----------------------------------------------------

    function deleteOwnOrg(string memory ownOrg) public  returns(bool){
        uint i = findOwnOrg(ownOrg);
        require(
            i != ownOrgs.length,
            "You don't own this org!"
        );
        delete ownOrgs[i];
        return true;
    }

    function deleteAdminOrg(string memory adminOrg) public returns(bool){
        uint i = findOwnOrg(adminOrg);
        require(
            i != adminOrgs.length,
            "You are not admin of this org!"
        );
        delete adminOrgs[i];
        return true;
    }

    function deleteMemberOrg(string memory memberOrg) public returns(bool){
        uint i = findOwnOrg(memberOrg);
        require(
            i != memberOrgs.length,
            "You are not member of this org!"
        );
        delete memberOrgs[i];
        return true;
    }
}