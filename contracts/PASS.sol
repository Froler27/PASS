pragma solidity >=0.4.21 <0.7.0;

import "./Certification.sol";
import "./Organization.sol";
import "./User.sol";

contract PASS{
    mapping(address => bool) _users;
    mapping(address => User) users;                 
    
    mapping(string => bool) _orgs;
    mapping(string => Organization) orgs;

    modifier onlyUsers{
        require(
            _users[msg.sender],
            "Only users can use this function! Please register!"
        );
        _;
    }

    function strcmp(string memory _str1, string memory _str2) public pure returns(bool) {
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

    // modifier check(string _str1,string _str2) {
    //     require(keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2)));
    //     _;
    // }
    
    //function register(string memory realName, string memory IDCardNum) public {
    function register() public {
        require(                        // 要求用户未注册过
            !_users[msg.sender],        
            "Don't register again!"
        );
        users[msg.sender] = new User();
        _users[msg.sender] = true;
    }

    function createOrg(string memory _orgName) public onlyUsers {
        require(                        // 要求组织名字唯一
            !_orgs[_orgName],        
            "The name has existed!"
        );
        orgs[_orgName] = new Organization(_orgName);
        _orgs[_orgName] = true;

        users[msg.sender].addOwnOrg(_orgName);
    }

    //-----------------------------

    function addAdminToOrg(address admin, string memory orgName) public{
        require(
            orgs[orgName].getCreator() == admin,
            "You are not the creator of the org!"
        );

        require(
            orgs[orgName].findAdmin(admin) == orgs[orgName].getAdmins().length,
            "You are not the creator of the org!"
        );

        orgs[orgName].addAdmin(admin);
    }

    function addMemberToOrg(address member, string memory orgName) public{

    }

    // 添加组织可颁发证书
    function addCertToOrg() public {

    }
}