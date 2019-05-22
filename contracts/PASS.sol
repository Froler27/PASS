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
        // 5 正在申请中
        // 6 拒绝颁发

        address owner;      // 证书获得者
        string origin;      // 证书的来源(组织)
        address sender;     // 证书的颁发者

        // uint receiptTime;   // 接收证书的时间
        // uint overdueTime;   // 证书的有效期限
        // uint sendTime;      // 证书在平台上颁发的时间
    }

    Certification[] certs;  // 存储证书实例

//------------------cert---------gets------2------固定
    // function getCertName(uint i) private view returns(string memory) {
    //     return certs[i].name;
    // }

    function getCertBody(uint i) public view returns(string memory) {
        return certs[i].body;
    }

    function getCertStatus(uint i) public view returns(uint) {
        return certs[i].status;
    }

//========================cert================================

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

    Invitation[] invs;

    struct User {
        address myself;
        string userinfo;

        uint[] ownOrgs;         // 用户创建的组织
        uint[] adminOrgs;       // 用户管理的组织
        uint[] memberOrgs;      // 用户加入的组织

        uint[] ownCerts;        // 用户获得的证书
        uint[] applyCerts;      // 用户申请获得证书的信息
        uint[] pendingCerts;    // 等待领取的证书

        uint[] invIDs;
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

//-------------------------User-----------3----------------

    function register(string memory userinfo) public {
        require(                        // 要求用户未注册过
            !(userIDs[msg.sender] > 0 && userIDs[msg.sender] < users.length),
            "Don't register again!"
        );
        User memory user;

        user.myself = msg.sender;
        user.userinfo = userinfo;
        users.push(user);
        if(users.length == 1)
            users.push(user);
        userIDs[msg.sender] = users.length - 1;
    }

    function getSelfAdr() public view returns(address){
        return msg.sender;
    }

    function getUserinfo(address userAdr) public view onlyUsers returns(string memory) {
        return users[userIDs[userAdr]].userinfo;
    }

    function getUserUintArr(address userAdr, uint8 i) public view returns(uint[] memory){
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

//=========================User=========================

    struct Organization{
        string name;
        address creator;        // getOrgCreator(orgName)
        address[] admins;       // getOrgAdmins(orgName)
        address[] members;      // getOrgMembers(orgName)

        string orginfo;

        string[] certs;
        uint[] issueCertIDs;

        uint[] applyCertIDs;
    }

    Organization[] orgs;
    mapping(string => uint) orgIDs;

//----------------------org----------5--------------

    function createOrg(string memory orgName, string memory orginfo) public onlyUsers returns(uint){
        require(                        // 要求组织名字唯一
            !(orgIDs[orgName] > 0 && orgIDs[orgName] < orgs.length),
            "The name has existed!"
        );

        Organization memory org;

        org.creator = msg.sender;
        org.orginfo = orginfo;
        org.name = orgName;

        orgs.push(org);
        if(orgs.length == 1)
            orgs.push(org);
        orgIDs[orgName] = orgs.length - 1;
        users[userIDs[msg.sender]].ownOrgs.push(orgIDs[orgName]);
        return orgs.length - 1;
    }

    // tag != 0 时返回组织可颁发证书信息
    function getOrginfo (uint tag, uint i, string memory orgName) public view returns(string memory) {
        if(tag == 0){
            if(i == 0)
                return orgs[orgIDs[orgName]].orginfo;
            return orgs[i].orginfo;
        }else{
            require(i<orgs[orgIDs[orgName]].certs.length,"exceed limit!");
            return orgs[orgIDs[orgName]].certs[i];
        }
    }

    // function dropOrg(string memory orgName) public existOrg(orgName) onlyCreator(orgName) {
    //     delete orgs[orgIDs[orgName]];
    //     delete orgIDs[orgName];
    // }

    function getOrgUserAdrs (uint i, string memory orgName) public view returns (address[] memory) {
        if(i == 1)
            return orgs[orgIDs[orgName]].admins;
        else if(i == 2)
            return orgs[orgIDs[orgName]].members;
        else
            require(false, "The first argument must be 1 or 2!");
    }

    // function getOrgCertName (string memory orgName, uint i) public view returns(string memory) {
    //     return orgs[orgIDs[orgName]].certs[i];
    // }

    function opOrgCertName (uint i, string memory orgName, string memory certName, uint certNameID) public {
        if(i == 1){
            orgs[orgIDs[orgName]].certs.push(certName);
        }else if(i == 2){
            delete orgs[orgIDs[orgName]].certs[certNameID];
        }
    }


    function getOrgCertIDs (uint i, string memory orgName) public view returns(uint[] memory) {
        if(i == 1)
            return orgs[orgIDs[orgName]].issueCertIDs;
        else if(i == 2)
            return orgs[orgIDs[orgName]].applyCertIDs;
        else
            require(false, "The first argument must be 1 or 2!");
    }

    function findOrgUser (uint tag, string memory orgName, address userAdr) private view returns (uint) {
        uint i;
        if(tag == 1){
            for(i = 0; i < orgs[orgIDs[orgName]].admins.length; i++)
                if(userAdr == orgs[orgIDs[orgName]].admins[i])
                    return i;
        }else if(tag == 2){
            for(i = 0; i < orgs[orgIDs[orgName]].members.length; i++)
                if(userAdr == orgs[orgIDs[orgName]].members[i])
                    return i;
        }
        return i;
    }


    /** */
    function deleteOrgUser (uint tag, string memory orgName, address userAdr) public {
        uint i;
        if(tag == 1){
            // require(
            //     msg.sender == orgs[orgIDs[orgName]].creator,
            //     "Only the creator of the org can use this function!"
            // );
            i = findOrgUser(1, orgName, userAdr);
            // require(
            //     i != orgs[orgIDs[orgName]].admins.length,
            //     "This user is not admin!"
            // );
            delete orgs[orgIDs[orgName]].admins[i];

        }else if(tag == 2){
            // require(
            //     (orgs[orgIDs[orgName]].admins.length != findOrgUser(1, orgName, msg.sender)) || msg.sender == orgs[orgIDs[orgName]].creator,
            //     "Only the admin or creator of the org can use this function!"
            // );
            i = findOrgUser(1, orgName, userAdr);
            // require(
            //     i != orgs[orgIDs[orgName]].members.length,
            //     "This user is not member!"
            // );
            delete orgs[orgIDs[orgName]].members[i];
        }
    }

    modifier onlyOrgMember(string memory orgName) {
        require(
            (orgs[orgIDs[orgName]].members.length != findOrgUser(2, orgName, msg.sender)) || (orgs[orgIDs[orgName]].admins.length != findOrgUser(1, orgName, msg.sender)) || msg.sender == orgs[orgIDs[orgName]].creator,
            "Only the member or admin or creator of the org can use this function!"
        );
        _;
    }

//===========================org=================================

//-------------------Invite------组织邀请用户加入-----3-------------

    function orgInvitesUser(string memory orgName, address receiver, uint8 site, string memory body) public onlyOrgMember(orgName) {
        Invitation memory inv;
        inv.orgName = orgName;
        inv.sender = msg.sender;
        inv.receiver = receiver;
        inv.site = site;
        inv.status = 3;
        inv.body = body;

        users[userIDs[msg.sender]].invIDs.push(invs.length);
        invs.push(inv);

        //users[userIDs[msg.sender]].invs.push(Invitation(orgName, msg.sender, receiver, 3, site, body));
    }

    function userCheckInv(uint invID, uint8 status) public{
        if(status == 0){
            delete invs[invID];
        }else{
            if(status == 1){
                if(invs[invID].site == 1){
                    require(
                        orgs[orgIDs[invs[invID].orgName]].admins.length == findOrgUser(1, invs[invID].orgName, msg.sender),
                        "This user is already admin!"
                    );
                    orgs[orgIDs[invs[invID].orgName]].admins.push(msg.sender);
                    users[userIDs[msg.sender]].adminOrgs.push(orgIDs[invs[invID].orgName]);
                    // addOrgAdmin(invs[invID].orgName, msg.sender);
                }else{
                    require(
                        orgs[orgIDs[invs[invID].orgName]].members.length == findOrgUser(2, invs[invID].orgName, msg.sender),
                        "This user is already member!"
                    );
                    users[userIDs[msg.sender]].memberOrgs.push(orgIDs[invs[invID].orgName]);
                    // addOrgMember(invs[invID].orgName, msg.sender);
                    orgs[orgIDs[invs[invID].orgName]].members.push(msg.sender);
                }
            }
                // acceptInv(invID);
            // else if(status == 2)
            //     rejectInv(invID);
            invs[invID].status = status;
        }
    }

    function getInvBody(uint invID) public view returns(string memory) {
        return invs[invID].body;
    }

//==========================Invite========================

//---------------------颁发证书---------------2----------------

    function orgIACert(uint tag, string memory certName, string memory certBody, address user, string memory orgName) public{
        uint i;
        for( i = 0; i < orgs[orgIDs[orgName]].certs.length ; i++)
            if(strcmp(certName, orgs[orgIDs[orgName]].certs[i]))
                break;
        require(
            i < orgs[orgIDs[orgName]].certs.length,
            "This org don't have this cert!"
        );
        require(
            userIDs[user] > 0 && userIDs[user] < users.length,
            "Certificates can only be issued to registered users!"
        );

        Certification memory cert;

        cert.name = certName;
        cert.body = certBody;
        cert.origin = orgName;
        if(tag == 1){
            cert.status = 2;
            cert.owner = user;
            cert.sender = msg.sender;
        }else if(tag == 2){
            cert.status = 5;
            cert.owner = msg.sender;
        }

        orgs[orgIDs[orgName]].issueCertIDs.push(certs.length);
        users[userIDs[user]].pendingCerts.push(certs.length);

        certs.push(cert);
    }

    function handlePendingCert(uint choice, uint certID, uint waitID) public {
        require(
            certs[certID].owner == msg.sender,
            "Only the gainer of the cert can receive it!"
        );
        if(choice == 1){
            certs[certID].status = 1;
            delete users[userIDs[msg.sender]].pendingCerts[waitID];
            users[userIDs[msg.sender]].ownCerts.push(certID);
        }else if(choice == 2){
            certs[certID].status = 3;
        }else if(choice == 3){
            certs[certID].status = 3;
            delete users[userIDs[msg.sender]].pendingCerts[waitID];
        }else{
            require(false, "The first argument must be 1 or 2 or 3!");
        }
    }

//============================颁发证书========================

    function handleCertApply(bool res, uint certID) public onlyOrgMember(certs[certID].origin) {
        if(res){
            certs[certID].status = 1;
            certs[certID].sender = msg.sender;
        }else{
            certs[certID].status = 6;
            certs[certID].sender = msg.sender;
        }
    }
}










   // function deleteCertApply(uint certID, uint i, uint j) private {
    //     delete certs[certID];
    //     delete users[userIDs[certs[certID].owner]].applyCerts[i];
    //     delete orgs[orgIDs[certs[certID].origin]].applyCertIDs[j];
    // }

    // function getCertOwner(uint i) private view returns(address) {
    //     return certs[i].owner;
    // }

    // function getCertOrigin(uint i) private view returns(string memory) {
    //     return certs[i].origin;
    // }

    // function getCertSender(uint i) private view returns(address) {
    //     return certs[i].sender;
    // }

    // modifier onlyCreator(string memory orgName) {
    //     require(
    //         msg.sender == orgs[orgIDs[orgName]].creator,
    //         "Only the creator of the org can use this function!"
    //     );
    //     _;
    // }

    // modifier existOrg(string memory orgName) {
    //     require(
    //         orgIDs[orgName] > 0 && orgIDs[orgName] < orgs.length,
    //         "This org has not been created!"
    //     );
    //     _;
    // }

    // function getOrgExist(string memory orgName) private view returns(bool) {
    //     return orgIDs[orgName] > 0 && orgIDs[orgName] < orgs.length;
    // }

    // function getOrgName(uint i) public view returns (string memory) {
    //     assert(i < orgs.length);
    //     return orgs[i].name;
    // }

    // function getOrgCertID (string memory orgName, string memory certName) private view existOrg(orgName) returns(uint) {
    //     uint i;
    //     for( i = 0; i < orgs[orgIDs[orgName]].certs.length ; i++)
    //         if(strcmp(certName, orgs[orgIDs[orgName]].certs[i]))
    //             return i;
    //     return i;
    // }

    // function judgeOrgCertExist (string memory orgName, string memory certName) private view returns (bool) {
    //     return getOrgCertID(orgName, certName) < orgs[orgIDs[orgName]].certs.length;
    // }

    // function judgeOrgAdmin(string memory orgName, address admin) private view returns(bool){
    //     return orgs[orgIDs[orgName]].admins.length != findOrgAdmin(orgName, admin);
    // }

    // function addOrgAdmin (string memory orgName, address admin) private {
    //     require(
    //         orgs[orgIDs[orgName]].admins.length == findOrgAdmin(orgName, admin),
    //         "This user is already admin!"
    //     );
    //     orgs[orgIDs[orgName]].admins.push(admin);
    // }

    // function acceptInv(uint invID) private{
    //     if(invs[invID].site == 1){
    //         users[userIDs[msg.sender]].adminOrgs.push(orgIDs[invs[invID].orgName]);
    //         addOrgAdmin(invs[invID].orgName, msg.sender);
    //     }else{
    //         users[userIDs[msg.sender]].memberOrgs.push(orgIDs[invs[invID].orgName]);
    //         addOrgMember(invs[invID].orgName, msg.sender);
    //     }
    // }

    // function rejectInv(uint invID) private{
    // }

    // modifier onlyAdmin(string memory orgName) {
    //     require(
    //         (orgs[orgIDs[orgName]].admins.length != findOrgAdmin(orgName, msg.sender)) || msg.sender == orgs[orgIDs[orgName]].creator,
    //         "Only the admin or creator of the org can use this function!"
    //     );
    //     _;
    // }

    // function test() public view returns (string memory){
    //     return users[userIDs[msg.sender]].userinfo;
    // }


    //-------------------Apply------用户申请加入组织------------------

    //==========================Apply========================

// function applyReadLimit(string memory orgName) private view onlyOrgMember(orgName) returns(bool){
//         return true;
//     }


    // function findUserOwnOrg(address userAdr, string memory orgName) private view returns(uint){
    //     uint i;
    //     for(i=0; i < users[userIDs[userAdr]].ownOrgs.length; i++)
    //         if(users[userIDs[userAdr]].ownOrgs[i] > 0 )
    //         if(strcmp(orgName, users[userIDs[userAdr]].ownOrgs[i]))
    //             return i;
    //     return i;
    // }

    // function judgeUserOwnOrg(address userAdr, string memory orgName) public view returns(bool){
    //     return users[userIDs[userAdr]].ownOrgs.length == findUserOwnOrg(userAdr, orgName);
    // }

    // function findUserAdminOrg(address userAdr, string memory orgName) public view returns(uint){
    //     uint i;
    //     for(i=0; i < users[userIDs[userAdr]].adminOrgs.length; i++)
    //         if(strcmp(orgName, users[userIDs[userAdr]].adminOrgs[i]))
    //             return i;
    //     return i;
    // }

    // function judgeUserAdminOrg(address userAdr, string memory orgName) public view returns(bool){
    //     return users[userIDs[userAdr]].adminOrgs.length == findUserAdminOrg(userAdr, orgName);
    // }

    // function findUserMemberOrg(address userAdr, string memory orgName) public view returns(uint){
    //     uint i;
    //     for(i=0; i < users[userIDs[userAdr]].memberOrgs.length; i++)
    //         if(strcmp(orgName, users[userIDs[userAdr]].memberOrgs[i]))
    //             return i;
    //     return i;
    // }

    // function judgeUserMemberOrg(address userAdr, string memory orgName) public view returns(bool){
    //     return users[userIDs[userAdr]].memberOrgs.length == findUserMemberOrg(userAdr, orgName);
    // }

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


// struct ApplyCertInfo{
//         address applicant;
//         string body;
//         // uint orgCertID;
//         uint status;
//         // 0 无
//         // 1 已查看
//         // 2 未查看
//         // 3 已同意
//         // 4 已拒绝
//     }

//  function getApplyBody(uint i, string memory orgName) public view returns(string memory){
//         if(applyCertInfos[i].applicant == msg.sender)
//             return applyCertInfos[i].body;
//         else if(applyReadLimit(orgName))
//             return applyCertInfos[i].body;
//         else
//             return '{"error": "You have no permission to see the details of this apply"}';
//     }

    // function orgChecksInfo(string memory orgName, uint ApplyCertInfoID) public {
    //     uint i = orgs[orgName].applyCertInfos[ApplyCertInfoID];
    //     applyCertInfos[i].status = 1;
    // }

//-------------------Member-------组织成员的操作------1--------------------

    // function findOrgMember (string memory orgName, address member) private view returns (uint) {
    //     uint i;
    //     for(i = 0; i < orgs[orgIDs[orgName]].members.length; i++)
    //         if(member == orgs[orgIDs[orgName]].members[i])
    //             return i;
    //     return i;
    // }

    // function judgeOrgMember(string memory orgName, address member) private view returns(bool){
    //     return orgs[orgIDs[orgName]].members.length != findOrgAdmin(orgName, member);
    // }

    // function addOrgMember (string memory orgName, address member) private {
    //     require(
    //         orgs[orgIDs[orgName]].members.length == findOrgAdmin(orgName, member),
    //         "This user is already member!"
    //     );
    //     orgs[orgIDs[orgName]].members.push(member);
    // }

    // function deleteOrgMember (string memory orgName, address member) public {
    //     require(
    //         (orgs[orgIDs[orgName]].admins.length != findOrgUser(1, orgName, msg.sender)) || msg.sender == orgs[orgIDs[orgName]].creator,
    //         "Only the admin or creator of the org can use this function!"
    //     );
    //     uint i = findOrgUser(1, orgName, member);
    //     require(
    //         i != orgs[orgIDs[orgName]].members.length,
    //         "This user is not member!"
    //     );
    //     delete orgs[orgIDs[orgName]].members[i];
    // }
//==========================Member=================================