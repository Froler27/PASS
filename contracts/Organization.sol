pragma solidity >=0.4.21 <0.7.0;

contract Organization{
    string name;            
    address creator;
    address[] admins;
    address[] members;
    uint createTime;  

    string[] certs; 
    mapping(string => address[]) certToUsers;
    mapping(string => mapping(address => uint)) statusOfCert;      // 证书的状态
    // 0 表示无
    // 1 已成功颁发
    // 2 等待用户接受
    // 3 用户拒绝接受
    // 4 证书已失效

    constructor(
        string memory _name
    ) public{
        name = _name;
        creator = msg.sender;
        createTime = now;
    }

    modifier onlyCreator{
        require(
            msg.sender == creator,
            "Only the creator can use this function!"
        );
        _;
    }

    modifier onlyAdmin{     // 包含了 creator 与 admin
        require(
            findAdmin(msg.sender) != admins.length || msg.sender == creator,
            "Only the creator can use this function!"
        );
        _;
    }

    modifier onlyMember{     // 包含了 creator、admin 与 member
        require(
            findMember(msg.sender) != members.length || findAdmin(msg.sender) != admins.length || msg.sender == creator,
            "Only the creator can use this function!"
        );
        _;
    }

    function strcmp(string memory _str1, string memory _str2) private pure returns(bool) {
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

    function getName () public view returns (string memory) {
        return name;
    }

    function getCreator () public view returns (address) {
        return creator;
    }

    function getAdmins () public view returns (address[] memory) {
        return admins;
    }

    function getMembers () public view returns (address[] memory) {
        return members;
    }

    function getCreatedTime () public view returns (uint) {
        return createTime;
    }

    //------------------------------------------------------------

    function findAdmin (address admin) public view returns (uint) {
        uint i;
        for(i=0; i<admins.length; i++)
            if(admin == admins[i])
                return i;
        return i;
    }

    function addAdmin (address admin) onlyCreator public {
        require(
            findAdmin(admin) == admins.length,
            "This user is already admin!"
        );
        admins.push(admin);
    }

    /** @dev 删除组织管理者
     *  @param admin 被删除者的地址
     *  @return 删除成功返回 true，否则返回 false
     */
    function deleteAdmin (address admin) onlyCreator public returns (bool) {
        uint i = findAdmin(admin);
        require(
            i != admins.length,
            "This user is not admin!"
        );
        delete admins[i];
        return true;
    }

    //---------------------------------------------------------------

    function findMember (address member) public view returns (uint) {
        uint i;
        for(i=0; i<members.length; i++)
            if(member == members[i])
                return i;
        return i;
    }

    function addMember (address member) onlyAdmin public {
        require(
            findMember(member) == members.length,
            "This user is already member!"
        );
        members.push(member);
    }

    /** @dev 删除组织成员
     *  @param member 被删除者的地址
     *  @return 删除成功返回 true，否则返回 false
     */
    function deleteMember (address member) onlyAdmin public returns (bool) {
        uint i = findMember(member);
        require(
            i != members.length,
            "This user is not member!"
        );
        delete members[i];
        return true;
    }


    //-----------------可颁发证书---------------------

    function findCert (string memory certName) public view returns (uint) {
        uint i;
        for(i=0; i<certs.length; i++)
            if(strcmp(certName, certs[i]))
                return i;
        return i;
    }

    function addCert (string memory certName) public {
        require(
            findCert(certName) == certs.length,
            "This certification has existed!"
        );
        certs.push(certName);
    }

    function deleteCert (string memory certName) public returns (bool) {
        uint i = findCert(certName);
        require(
            i != certs.length,
            "This certification has not been added!"
        );
        delete certs[i];
        return true;
    }


    // -----------------颁发证书-------------------

    modifier checkCert (string memory certName) {   // 要求可颁发证书存在
        require(
            findCert(certName) != certs.length,
            "This certification has not been added!"
        );
        _;
    }

    function getUsersOfCert (string memory certName) public view checkCert(certName) returns (address[] memory) {
        return certToUsers[certName];
    }

    function findUserOfCert (string memory certName, address userOfCert) public view returns (uint) {
        address[] memory usersOfCert = getUsersOfCert(certName);
        uint i;
        for(i=0; i<usersOfCert.length; i++)
            if(userOfCert == usersOfCert[i])
                return i;
        return i;
    }

    modifier checkUser (string memory certName, address user) {
        uint i = findUserOfCert(certName, user);   
        require(
            i < certToUsers[certName].length,
            "No certification issues this user!"
        );
        _;
    }

    function issueCert (string memory certName, address user) public onlyMember checkCert(certName) {
        uint icert = findCert(certName);                // 可颁发证书索引
        uint iuser = findUserOfCert(certName, user);    // 获得特定证书用户的索引
        require(
            iuser == certToUsers[certName].length,      // 要求证书还未颁发给用户
            "The certiication has been issued to this user!"
        );
        certToUsers[certName][icert] = user;
        statusOfCert[certName][user] = 2;
    } 

    function getStatusOfCert (string memory certName, address user) public view checkUser(certName, user) returns (uint) {
        // 0 表示无
        // 1 已成功颁发
        // 2 等待用户接受
        // 3 用户拒绝接受
        // 4 证书已失效
        return statusOfCert[certName][user];
    }

    function setStatusOfCert (string memory certName, address user, uint status) public {
        
        statusOfCert[certName][user] = status;
    }
}