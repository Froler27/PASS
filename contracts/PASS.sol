pragma solidity >=0.4.21 <0.7.0;

import "./Certification.sol";

contract PASS{

    function strcmp(string memory _str1, string memory _str2) private pure returns(bool) {
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

    struct User {
        string nickName;
        string realName;
        string IDCardNum;
        uint registerTime; 
        bool exist;

        string[] ownOrgs;          // 用户创建的组织
        string[] adminOrgs;        // 用户管理的组织
        string[] memberOrgs;       // 用户加入的组织
    }

    modifier onlyUsers{
        require(
            users[msg.sender].exist,
            "Only users can use this function! Please register!"
        );
        _;
    }

    address[] usersAdrs;
    mapping(address => User) users;   

    function register(string memory nickName) public {
        require(                        // 要求用户未注册过
            !users[msg.sender].exist,        
            "Don't register again!"
        );
        users[msg.sender].nickName = nickName;
        users[msg.sender].registerTime = now;
        users[msg.sender].exist = true;
        usersAdrs.push(msg.sender);
    }

    //-----------------------------------------------------------------------

    /** @dev 获取所有用户的地址
     */
    function getAllUsers() public view returns(address[] memory){
        return usersAdrs;
    }

    function getUserNickName(address userAdr) public view returns(string memory) {
        return users[userAdr].nickName;
    }

    function getUserRegisterTime(address userAdr) public view returns(uint) {
        return users[userAdr].registerTime;
    }

    function getUserExist(address userAdr) public view returns(bool) {
        return users[userAdr].exist;
    }

    //====================================================================

    //-------------------------------------------------------------------

    function findUserOwnOrg(address userAdr, string memory orgName) public view returns(uint){
        uint i;
        for(i=0; i < users[userAdr].ownOrgs.length; i++)
            if(strcmp(orgName, users[userAdr].ownOrgs[i]))
                return i;
        return i;
    }

    function judgeUserOwnOrg(address userAdr, string memory orgName) public view returns(bool){
        return users[userAdr].ownOrgs.length == findUserOwnOrg(userAdr, orgName);
    }

    function findUserAdminOrg(address userAdr, string memory orgName) public view returns(uint){
        uint i;
        for(i=0; i < users[userAdr].adminOrgs.length; i++)
            if(strcmp(orgName, users[userAdr].adminOrgs[i]))
                return i;
        return i;
    }

    function judgeUserAdminOrg(address userAdr, string memory orgName) public view returns(bool){
        return users[userAdr].adminOrgs.length == findUserAdminOrg(userAdr, orgName);
    }

    function findUserMemberOrg(address userAdr, string memory orgName) public view returns(uint){
        uint i;
        for(i=0; i < users[userAdr].memberOrgs.length; i++)
            if(strcmp(orgName, users[userAdr].memberOrgs[i]))
                return i;
        return i;
    }

    function judgeUserMemberOrg(address userAdr, string memory orgName) public view returns(bool){
        return users[userAdr].memberOrgs.length == findUserMemberOrg(userAdr, orgName);
    }

    //=====================================================================

    //---------------------------------------------------------------------

    function addUserOwnOrg(string memory orgName) public onlyUsers{
        require(
            !judgeUserOwnOrg(msg.sender, orgName),
            "You have owned this org!"
        );
        users[msg.sender].ownOrgs.push(orgName);
    }

    function addUserAdminOrg(string memory orgName) public onlyUsers{
        require(
            !judgeUserAdminOrg(msg.sender, orgName),
            "You have admined this org!"
        );
        users[msg.sender].adminOrgs.push(orgName);
    }

    function addUserMemberOrg(string memory orgName) public onlyUsers{
        require(
            !judgeUserMemberOrg(msg.sender, orgName),
            "You have been member of this org!"
        );
        users[msg.sender].memberOrgs.push(orgName);
    }

    //=====================================================================

    //---------------------------------------------------------------------
    
    function deleteOwnOrg(string memory orgName) public {
        uint i = findUserOwnOrg(msg.sender, orgName);
        require(
            i != users[msg.sender].ownOrgs.length,
            "You don't own this org!"
        );
        delete users[msg.sender].ownOrgs[i];
    }

    function deleteAdminOrg(string memory orgName) public {
        uint i = findUserAdminOrg(msg.sender, orgName);
        require(
            i != users[msg.sender].adminOrgs.length,
            "You don't admin this org!"
        );
        delete users[msg.sender].ownOrgs[i];
    }

    function deleteMemberOrg(string memory orgName) public {
        uint i = findUserMemberOrg(msg.sender, orgName);
        require(
            i != users[msg.sender].memberOrgs.length,
            "You are not the member of this org!"
        );
        delete users[msg.sender].ownOrgs[i];
    }

    //=====================================================================


    struct Organization{       
        address creator;
        address[] admins;
        address[] members;
        uint createTime; 
        bool exist; 

        string[] certs; 
        mapping(string => address[]) certToUsers;
        mapping(string => mapping(address => uint)) statusOfCert;      // 证书的状态
        // 0 表示无
        // 1 已成功颁发
        // 2 等待用户接受
        // 3 用户拒绝接受
        // 4 证书已失效
    }

    string[] orgNames;
    mapping(string => Organization) orgs;

    

    function createOrg(string memory orgName) public onlyUsers {
        require(                        // 要求组织名字唯一
            !orgs[orgName].exist,        
            "The name has existed!"
        );
        orgs[orgName].creator = msg.sender;
        orgs[orgName].createTime = now;
        orgNames.push(orgName);
        
        addUserOwnOrg(orgName);
    }

    modifier onlyCreator(string memory orgName) {
        require(
            msg.sender == orgs[orgName].creator,
            "Only the creator of the org can use this function!"
        );
        _;
    }

    //-----------------------------------------------------------------------

    function getOrgName (uint i) public view returns(string memory){
        return orgNames[i];
    }

    function getOrgCreator (string memory orgName) public view returns(address) {
        return orgs[orgName].creator;
    }

    function getOrgAdmins (string memory orgName) public view returns (address[] memory) {
        return orgs[orgName].admins;
    }

    function getOrgMembers (string memory orgName) public view returns (address[] memory) {
        return orgs[orgName].members;
    }

    function getOrgCreatedTime (string memory orgName) public view returns (uint) {
        return orgs[orgName].createTime;
    }

    //====================================================================

    
    //--------------------------Admin---------------------------------

    function findOrgAdmin (string memory orgName, address admin) public view returns (uint) {
        uint i;
        for(i=0; i<orgs[orgName].admins.length; i++)
            if(admin == orgs[orgName].admins[i])
                return i;
        return i;
    }

    function judgeOrgAdmin(string memory orgName, address admin) public view returns(bool){
        return orgs[orgName].admins.length != findOrgAdmin(orgName, admin);
    }

    function addOrgAdmin (string memory orgName, address admin) onlyCreator(orgName) public {
        require(
            !judgeOrgAdmin(orgName, admin),
            "This user is already admin!"
        );
        orgs[orgName].admins.push(admin);
    }

    function deleteOrgAdmin (string memory orgName, address admin) onlyCreator(orgName) public {
        uint i = findOrgAdmin(orgName, admin);
        require(
            i != orgs[orgName].admins.length,
            "This user is not admin!"
        );
        delete orgs[orgName].admins[i];
    }

    modifier onlyAdmin(string memory orgName) {
        require(
            judgeOrgAdmin(orgName, msg.sender) || msg.sender == orgs[orgName].creator,
            "Only the admin or creator of the org can use this function!"
        );
        _;
    }

    //==========================Admin=================================
    
    //--------------------------Member---------------------------------
    
    function findOrgMember (string memory orgName, address member) public view returns (uint) {
        uint i;
        for(i=0; i < orgs[orgName].members.length; i++)
            if(member == orgs[orgName].members[i])
                return i;
        return i;
    }

    function judgeOrgMember(string memory orgName, address member) public view returns(bool){
        return orgs[orgName].members.length != findOrgAdmin(orgName, member);
    }

    function addOrgMember (string memory orgName, address member) onlyAdmin(orgName) public {
        require(
            !judgeOrgMember(orgName, member),
            "This user is already member!"
        );
        orgs[orgName].members.push(member);
    }

    function deleteOrgMember (string memory orgName, address member) onlyAdmin(orgName) public {
        uint i = findOrgAdmin(orgName, member);
        require(
            i != orgs[orgName].members.length,
            "This user is not member!"
        );
        delete orgs[orgName].members[i];
    }

    modifier onlyOrgMember(string memory orgName) {
        require(
            judgeOrgMember(orgName, msg.sender) || judgeOrgAdmin(orgName, msg.sender) || msg.sender == orgs[orgName].creator,
            "Only the member or admin or creator of the org can use this function!"
        );
        _;
    }

    //==========================Member=================================


                 
    
    
    
    

    constructor() public{
    }

    

   

    // function addAdminToOrg(address admin, string memory orgName) public{
    //     require(
    //         orgs[orgName].getCreator() == admin,
    //         "You are not the creator of the org!"
    //     );

    //     require(
    //         orgs[orgName].findAdmin(admin) == orgs[orgName].getAdmins().length,
    //         "You are not the creator of the org!"
    //     );

    //     orgs[orgName].addAdmin(admin);
    // }
    
    function test() public view returns (string memory){
        return users[msg.sender].nickName;
    }
}