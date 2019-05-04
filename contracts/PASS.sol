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

        // uint receiptTime;   // 接收证书的时间
        // uint overdueTime;   // 证书的有效期限
        // uint sendTime;      // 证书在平台上颁发的时间
    }

    Certification[] certs;  // 存储证书实例


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


    //##########################################################

    struct Invitation {
        string orgName;
        address sender;
        address receiver;
        uint8 status;
        // 1 同意
        // 2 拒绝
        // 3 未查看
        // 4 已查看
        uint8 site;
        // 1 管理员
        // 2 成员
        string body;
    }

    struct User {
        address myself;
        string userinfo;

        uint[] ownOrgs;         // 用户创建的组织
        uint[] adminOrgs;       // 用户管理的组织
        uint[] memberOrgs;      // 用户加入的组织

        uint[] ownCerts;        // 用户获得的证书
        uint[] applyCerts;      // 用户申请获得证书的信息
        uint[] pendingCerts;    // 等待领取的证书

        Invitation[] invs;
    }

    modifier onlyUsers{
        require(
            userIDs[msg.sender] > 0 && userIDs[msg.sender] < users.length,
            "Only users can use this function! Please register!"
        );
        _;
    }

    User[] users;
    mapping(address => uint) userIDs;   

    function register(string memory userinfo) public {
        require(                        // 要求用户未注册过
            !(userIDs[msg.sender] > 0 && userIDs[msg.sender] < users.length),        
            "Don't register again!"
        );
        User memory user;

        user.myself = msg.sender;
        user.userinfo = userinfo;

        users.push(user);
    }

    function getSelfAdr() public view returns(address){
        return msg.sender;
    }

    //-----------------------------------------------------------------------

    /** @dev 获取所有用户的地址
     */
    // function getUserAdr() public view returns(address){
    //     return usersAdrs;
    // }

    function getUserinfo(address userAdr) public view returns(string memory) {
        return users[userIDs[userAdr]].userinfo;
    }

    //====================================================================

    //-------------------------------------------------------------------

    /** @dev 获取用户组织或证书的编号
     */
    function getUserUintArr(address userAdr, uint8 i) public returns(uint[] memory){
        if(i==1)
            return users[userIDs[userAdr]].ownOrgs;
        else if(i==2)
            return users[userIDs[userAdr]].adminOrgs;
        else if(i==3)
            return users[userIDs[userAdr]].memberOrgs;
        else if(i==4)
            return users[userIDs[userAdr]].ownCerts;
        else if(i==5)
            return users[userIDs[userAdr]].applyCerts;
        else if(i==6)
            return users[userIDs[userAdr]].pendingCerts;
        else
            require(
                false,
                "The second argument must >= 1 and <= 6 !"
            );
    }

    function findUserOwnOrg(address userAdr, string memory orgName) private view returns(uint){
        uint i;
        for(i=0; i < users[userIDs[userAdr]].ownOrgs.length; i++)
            if(users[userIDs[userAdr]].ownOrgs[i] > 0 )
            if(strcmp(orgName, users[userIDs[userAdr]].ownOrgs[i]))
                return i;
        return i;
    }

    function judgeUserOwnOrg(address userAdr, string memory orgName) public view returns(bool){
        return users[userIDs[userAdr]].ownOrgs.length == findUserOwnOrg(userAdr, orgName);
    }

    function findUserAdminOrg(address userAdr, string memory orgName) public view returns(uint){
        uint i;
        for(i=0; i < users[userIDs[userAdr]].adminOrgs.length; i++)
            if(strcmp(orgName, users[userIDs[userAdr]].adminOrgs[i]))
                return i;
        return i;
    }

    function judgeUserAdminOrg(address userAdr, string memory orgName) public view returns(bool){
        return users[userIDs[userAdr]].adminOrgs.length == findUserAdminOrg(userAdr, orgName);
    }

    function findUserMemberOrg(address userAdr, string memory orgName) public view returns(uint){
        uint i;
        for(i=0; i < users[userIDs[userAdr]].memberOrgs.length; i++)
            if(strcmp(orgName, users[userIDs[userAdr]].memberOrgs[i]))
                return i;
        return i;
    }

    function judgeUserMemberOrg(address userAdr, string memory orgName) public view returns(bool){
        return users[userIDs[userAdr]].memberOrgs.length == findUserMemberOrg(userAdr, orgName);
    }

    // //=====================================================================

    // //---------------------------------------------------------------------




    // function addUserMemberOrg(string memory orgName) public onlyUsers{
    //     require(
    //         !judgeUserMemberOrg(msg.sender, orgName),
    //         "You have been member of this org!"
    //     );
    //     users[msg.sender].memberOrgs.push(orgName);
    // }

    // //=====================================================================

    // //---------------------------------------------------------------------
    
    // function deleteOwnOrg(string memory orgName) public {
    //     uint i = findUserOwnOrg(msg.sender, orgName);
    //     require(
    //         i != users[msg.sender].ownOrgs.length,
    //         "You don't own this org!"
    //     );
    //     delete users[msg.sender].ownOrgs[i];
    //     dropOrg(orgName);
    // }

    // function deleteAdminOrg(string memory orgName) public {
    //     uint i = findUserAdminOrg(msg.sender, orgName);
    //     uint j = findOrgAdmin(orgName, msg.sender);
    //     require(
    //         i != users[msg.sender].adminOrgs.length,
    //         "You don't admin this org!"
    //     );
    //     delete users[msg.sender].adminOrgs[i];
    //     require(
    //         j != orgs[orgName].admins.length,
    //         "You are not the admin of the org!"
    //     );
    //     delete orgs[orgName].admins[j];
    // }

    // function deleteMemberOrg(string memory orgName) public {
    //     uint i = findUserMemberOrg(msg.sender, orgName);
    //     uint j = findOrgMember(orgName, msg.sender);
    //     require(
    //         i != users[msg.sender].memberOrgs.length,
    //         "You are not the member of this org!"
    //     );
    //     delete users[msg.sender].memberOrgs[i];
    //     require(
    //         j != orgs[orgName].members.length,
    //         "The org member list doesn't have your name!"
    //     );
    //     delete orgs[orgName].members[i];
    // }

    //=====================================================================

    struct ApplyInfo{
        address applicant;
        string body;
        // uint orgCertID;
        uint status;
        // 0 无
        // 1 已查看
        // 2 未查看
        // 3 已同意
        // 4 已拒绝
    }
    
    ApplyInfo[] applyInfos;

    struct Organization{  
        string name;     
        address creator;        // getOrgCreator(orgName)
        address[] admins;       // getOrgAdmins(orgName)
        address[] members;      // getOrgMembers(orgName)

        string orginfo;

        string[] certs; 
        
        //mapping(string => mapping(address => uint[])) certIDs;
        uint[] certIDs;
        uint[] applyInfos;
    }

    Organization[] orgs;
    mapping(string => uint) orgIDs;
    
    function createOrg(string memory orgName, string memory orginfo) public onlyUsers {
        require(                        // 要求组织名字唯一
            !(orgIDs[orgName] > 0 && orgIDs[orgName] < orgs.length),        
            "The name has existed!"
        );

        Organization memory org;

        org.creator = msg.sender;
        org.orginfo = orginfo;
        org.name = orgName;

        orgIDs[orgName] = orgs.length;
        orgs.push(org);
        
        users[userIDs[msg.sender]].ownOrgs.push(orgIDs[orgName]);
    }

    modifier onlyCreator(string memory orgName) {
        require(
            msg.sender == orgs[orgIDs[orgName]].creator,
            "Only the creator of the org can use this function!"
        );
        _;
    }

    modifier existOrg(string memory orgName) {
        require(
            orgIDs[orgName] > 0 && orgIDs[orgName] < orgs.length,
            "This org has not been created!"
        );
        _;
    }

    function getOrgNum() public returns(uint){
        return orgs.length;
    }

    function getOrgName(uint i) public returns (string memory) {
        assert(i < orgs.length);
        return orgs[i].name;
    }

    function dropOrg(string memory orgName) public existOrg(orgName) onlyCreator(orgName) {
        delete orgs[orgIDs[orgName]];
        delete orgIDs[orgName];
    }

    //-----------------------------------------------------------------------

    function getOrgCertName (string memory orgName) public view existOrg(orgName) returns(string memory) {
        return orgs[orgIDs[orgName]].name;
    }

    function getOrgCertID (string memory orgName, string memory certName) public view existOrg(orgName) returns(uint) {
        uint i;
        for(i=0; i<orgs[orgIDs[orgName]].certs.length; i++)
            if(strcmp(certName, orgs[orgIDs[orgName]].certs[i]))
                return i;
        return i;
    }

    function judgeOrgCertExist (string memory orgName, string memory certName) public view returns (bool) {
        return getOrgCertID(orgName, certName) < orgs[orgIDs[orgName]].certs.length;
    }

    function getOrgCreator (string memory orgName) public view existOrg(orgName) returns(address) {
        return orgs[orgIDs[orgName]].creator;
    }

    function getOrgAdmins (string memory orgName) public view existOrg(orgName) returns (address[] memory) {
        return orgs[orgIDs[orgName]].admins;
    }

    function getOrgMembers (string memory orgName) public view existOrg(orgName) returns (address[] memory) {
        return orgs[orgIDs[orgName]].members;
    }

    function getOrgExist(string memory orgName) public view returns(bool) {
        return orgIDs[orgName] > 0 && orgIDs[orgName] < orgs.length;
    }

    //====================================================================

    
    //--------------------------Admin---------------------------------

    function findOrgAdmin (string memory orgName, address admin) private view returns (uint) {
        uint i;
        for(i=0; i<orgs[orgIDs[orgName]].admins.length; i++)
            if(admin == orgs[orgIDs[orgName]].admins[i])
                return i;
        return i;
    }

    function judgeOrgAdmin(string memory orgName, address admin) private view returns(bool){
        return orgs[orgIDs[orgName]].admins.length != findOrgAdmin(orgName, admin);
    }

    function addOrgAdmin (string memory orgName, address admin) private {
        require(
            !judgeOrgAdmin(orgName, admin),
            "This user is already admin!"
        );
        orgs[orgIDs[orgName]].admins.push(admin);
    }

    /** */
    function deleteOrgAdmin (string memory orgName, address admin) onlyCreator(orgName) public {
        uint i = findOrgAdmin(orgName, admin);
        require(
            i != orgs[orgIDs[orgName]].admins.length,
            "This user is not admin!"
        );
        delete orgs[orgIDs[orgName]].admins[i];
    }

    modifier onlyAdmin(string memory orgName) {
        require(
            judgeOrgAdmin(orgName, msg.sender) || msg.sender == orgs[orgIDs[orgName]].creator,
            "Only the admin or creator of the org can use this function!"
        );
        _;
    }

    //==========================Admin=================================
    
    //--------------------------Member---------------------------------
    
    function findOrgMember (string memory orgName, address member) private view returns (uint) {
        uint i;
        for(i=0; i < orgs[orgIDs[orgName]].members.length; i++)
            if(member == orgs[orgIDs[orgName]].members[i])
                return i;
        return i;
    }

    function judgeOrgMember(string memory orgName, address member) private view returns(bool){
        return orgs[orgIDs[orgName]].members.length != findOrgAdmin(orgName, member);
    }

    function addOrgMember (string memory orgName, address member) private {
        require(
            !judgeOrgMember(orgName, member),
            "This user is already member!"
        );
        orgs[orgIDs[orgName]].members.push(member);
    }

    function deleteOrgMember (string memory orgName, address member) onlyAdmin(orgName) public {
        uint i = findOrgAdmin(orgName, member);
        require(
            i != orgs[orgIDs[orgName]].members.length,
            "This user is not member!"
        );
        delete orgs[orgIDs[orgName]].members[i];
    }

    modifier onlyOrgMember(string memory orgName) {
        require(
            judgeOrgMember(orgName, msg.sender) || judgeOrgAdmin(orgName, msg.sender) || msg.sender == orgs[orgIDs[orgName]].creator,
            "Only the member or admin or creator of the org can use this function!"
        );
        _;
    }

    //==========================Member=================================
    

    //--------------------------Invite------------------------

    function orgInvitesUser(string memory orgName, address receiver, uint8 site, string memory body) public onlyOrgMember(orgName) {
        Invitation memory inv;
        inv.orgName = orgName;
        inv.sender = msg.sender;
        inv.receiver = receiver;
        inv.site = site;
        inv.status = 3;
        inv.body = body;
        
        users[userIDs[msg.sender]].invs.push(inv);
    }

    function acceptInv(uint invID) private{
        if(users[userIDs[msg.sender]].invs[invID].site == 1){
            users[userIDs[msg.sender]].adminOrgs.push(orgIDs[users[userIDs[msg.sender]].invs[invID].orgName]);
            addOrgAdmin(users[userIDs[msg.sender]].invs[invID].orgName, msg.sender);
        }else{
            users[userIDs[msg.sender]].memberOrgs.push(orgIDs[users[userIDs[msg.sender]].invs[invID].orgName]);
            addOrgMember(users[userIDs[msg.sender]].invs[invID].orgName, msg.sender);
        }
    }

    function rejectInv(uint invID) private{
    }

    function userCheckInv(uint invID, uint8 status) public{
        if(status == 0){
            delete users[userIDs[msg.sender]].invs[invID];
        }else{
            if(status == 1)
                acceptInv(invID);
            else if(status == 2)
                rejectInv(invID);
            users[userIDs[msg.sender]].invs[invID].status = status;
        }
    }

    function getInvBody(uint invID) public view returns(string memory) {
        return users[userIDs[msg.sender]].invs[invID].body;
    }

    //==========================Invite========================

    function orgIssuesCert(string memory certName, string memory certBody, address user, string memory orgName, uint overdueTime) public onlyOrgMember(orgName) {
        uint certID = certs.length;

        Certification memory cert;
        cert.name = certName;
        cert.body = certBody;
        cert.status = 2;
        cert.owner = user;
        cert.origin = orgName;
        cert.sender = msg.sender;
        certs.push(cert);
        
        orgs[orgIDs[orgName]].certIDs[certName][user].push(certID);
        users[user].pendingCerts.push(certID);
    }


    function receiveCert(uint certID, uint waitID) public {
        require(
            certs[certID].owner == msg.sender,
            "Only the gainer of the cert can receive it!"
        );
        certs[certID].status = 1;
        delete users[msg.sender].pendingCerts[waitID];
        users[msg.sender].ownCerts.push(certID);
    }

    function rejectCert(uint certID, uint waitID) public {
        require(
            certs[certID].owner == msg.sender,
            "Only the gainer of the cert can reject it!"
        );
        certs[certID].status = 3;
        delete users[msg.sender].pendingCerts[waitID];
    }


    //------------------------Apply------------------------------

    function applyCertToOrg(string memory certName, string memory orgName, string memory body) public {
        uint i = getOrgCertID(orgName, certName);
        require(
            i < orgs[orgName].certs.length,
            "This org don't have this cert!"
        );
        ApplyInfo memory applyInfo;
        applyInfo.applicant = msg.sender;
        applyInfo.orgCertID = i;
        applyInfo.applyTime = now;
        applyInfo.status = 2;
        applyInfo.body = body;

        applyInfos.push(applyInfo);
        users[msg.sender].applyCerts.push(applyInfos.length - 1);
        orgs[orgName].applyInfos.push(applyInfos.length - 1);
    }

    function applyReadLimit(string memory orgName) private view onlyOrgMember(orgName) returns(bool){
        return true;
    }

    function getApplyBody(uint i, string memory orgName) public view returns(string memory){
        if(applyInfos[i].applicant == msg.sender)
            return applyInfos[i].body;
        else if(applyReadLimit(orgName))
            return applyInfos[i].body;
        else
            return '{"error": "You have no permission to see the details of this apply"}';
    }

    function getUserapplyCertsID () public view returns(uint[] memory) {
        return users[msg.sender].applyCerts;
    }

    function getOrgapplyCertsID (string memory orgName) public view returns(uint[] memory) {
        return orgs[orgName].applyInfos;
    }

    function getApplyDetail(uint i) public view returns(uint[3] memory){
        uint[3] memory args;
        args[0] = applyInfos[i].orgCertID;
        args[1] = applyInfos[i].applyTime;
        args[2] = applyInfos[i].status;
        return args;
    }

    function orgChecksInfo(string memory orgName, uint applyInfoID) public {
        uint i = orgs[orgName].applyInfos[applyInfoID];
        applyInfos[i].status = 1;
    }

    //==========================Apply==========================

    
    function test() public view returns (string memory){
        return users[msg.sender].nickName;
    }


}