pragma solidity >=0.4.21 <0.7.0;

contract PASS{

    function strcmp(string memory _str1, string memory _str2) private pure returns(bool) {
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

    struct Certification {
        string name;
        string body; 
        uint status;        // 证书的状态
        // 0 表示无
        // 1 已成功颁发并生效
        // 2 等待用户接受
        // 3 用户拒绝接受
        // 4 证书已失效
        
        address owner;      // 证书获得者
        string origin;      // 证书的来源(组织)
        address sender;     // 证书的颁发者

        uint receiptTime;   // 接收证书的时间
        uint overdueTime;   // 证书的有效期限
        uint sendTime;      // 证书在平台上颁发的时间
    }

    Certification[] certs;

    function createCert(string memory certName, string memory certBody, address user, string memory origin, uint overdueTime) public returns(uint){
        Certification memory cert;
        cert.name = certName;
        cert.body = certBody;
        cert.owner = user;
        cert.origin = origin;
        cert.overdueTime = overdueTime;
        cert.sender = msg.sender;
        certs.push(cert);

        return certs.length-1;
    }

    function getCertName(uint i) public view returns(string memory) {
        return certs[i].name;
    }

    function getCertBody(uint i) public view returns(string memory) {
        return certs[i].body;
    }

    function getCertStatus(uint i) public view returns(uint) {
        return certs[i].status;
    }

    function getCertOwner(uint i) public view returns(address) {
        return certs[i].owner;
    }

    function getCertOrigin(uint i) public view returns(string memory) {
        return certs[i].origin;
    }

    function getCertSender(uint i) public view returns(address) {
        return certs[i].sender;
    }

    function getCertReceiptTime(uint i) public view returns(uint) {
        return certs[i].receiptTime;
    }

    function getCertOverdueTime(uint i) public view returns(uint) {
        return certs[i].overdueTime;
    }

    function getCertSendTime(uint i) public view returns(uint) {
        return certs[i].sendTime;
    }

    //##########################################################

    struct User {
        string nickName;
        string realName;
        string IDCardNum;
        uint registerTime; 
        bool exist;

        string[] ownOrgs;          // 用户创建的组织
        string[] adminOrgs;        // 用户管理的组织
        string[] memberOrgs;       // 用户加入的组织

        uint[] ownCerts;
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

    function getSelfAdr() public view returns(address){
        return msg.sender;
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

    struct applyInfo{
        address applicant;
        uint certSite;
        uint applyTime;
        uint status;
        // 0 无
        // 1 已查看
        // 2 未查看
        // 3 已同意
        // 4 已拒绝
    }

    struct Organization{       
        address creator;
        address[] admins;
        address[] members;
        uint createTime; 
        bool exist; 

        string[] certs; 
        mapping(string => address[]) certToUsers;
        mapping(string => mapping(address => uint)) certID;

        applyInfo[] infos;
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

    function getOrgExist(string memory orgName) public view returns(bool) {
        return orgs[orgName].exist;
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


    function receiveCert(uint certID) public {
        require(
            certs[certID].owner == msg.sender,
            "Only the gainer of the cert can receive it!"
        );
        certs[certID].status = 1;
    }

    function rejectCert(uint certID) public {
        require(
            certs[certID].owner == msg.sender,
            "Only the gainer of the cert can reject it!"
        );
        certs[certID].status = 3;
    }

    function applyCertToOrg(string memory certName, string memory orgName) public {
        require(
            orgs[orgName].exist,
            "This org has not been created!"
        );
    }
    
    function test() public view returns (string memory){
        return users[msg.sender].nickName;
    }


}