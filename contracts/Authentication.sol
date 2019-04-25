import "./Certification.sol";

library CommonFun{
    // /** 动态删除一个数组元素 */
    // function delArrayElByIndex(uint[] memory arr, uint index) internal returns(bool) {
    //     return true;
    // }
}



/** @title 认证 */
contract Authentication {

    struct Certification {                          // 证书
        string proof;                               // 证书验证信息
        string name;                                // 证书名称
        uint16 status;                              // 证书的状态
        string origin;                              // 证书的来源
        string details;                             // 证书详细内容
    }

    struct User{                                    
        uint balance;                               // 账户 PASS币 余额
        Certification[] acquiredCerts;              // 已经获得的证书
        Certification[] applyingCerts;              // 正在申请的证书
        Certification[] certTemps;                  // 自定义的证书
    }

    // 组织的数据结构
    struct Organization {                           
        string name;                                // 组织的名称
        address creator;                            // 组织创建者
        address[] admins;                           // 组织管理者
        address[] members;                          // 组织成员

        mapping(string => uint) typeOfCert; 

        // 待实现：可授权给其他组织颁发证书
    }
    

    mapping(address => User) users;                 // 记录用户数据
    Organization[] organizations;                   // 记录已创建的组织
    Certification[] certTemps;                      // 存储证书的模板
    
    

    /** @dev 为用户创建一个账户
     *  @param name 用户的名字
     *  @return 创建成功返回 true，否则返回 false
     */
    function createAccount(string memory name) public returns (bool) {
        users[msg.sender].name = name;              // 设置用户名称
        users[msg.sender].balance = 0;              // 初始化用户余额

        return true;
    }


    /** @dev 创建一个组织
     *  @param name 组织的名字
     *  @param owners 组织的拥有者
     *  @return 创建成功返回 true，否则返回 false
     */
    function createOrganization(string memory name, address[] memory owners) public returns (bool) {
        Organization memory org;                    // 创建临时的组织
        org.name = name;                            // 设置组织名字
        for(uint i=0; i<owners.length; i++){        // 设置组织拥有者
            org.owners[i] = owners[i];
        }
        organizations.push(org);                    // 将组织信息保存到区块链中

        return true;
    }

    /** @dev 获取用户的信息
     */
    function getUserInfo(address user) public view returns (string memory) {

        return users[user].name;
    }

    /** @dev 查看用户获得的证书
     */
    function getOneUserAcquiredCert(address user, uint i) public view returns (string memory) {

        if(users[user].acquiredCerts.length == 0)
            return "用户还未获得过证书";

        assert(i < 0 || i >= users[user].acquiredCerts.length);
        return users[user].acquiredCerts[i].name;
    }


    /** @dev 查看用户正在申请的证书
     */
    function getOneUserApplyingCert(address user, uint i) public view returns (string memory) {
        
        if(users[user].applyingCerts.length == 0)
            return "用户没有正在申请的证书";

        assert(i < 0 || i >= users[user].applyingCerts.length);
        return users[user].applyingCerts[i].name;
    }


    /** @dev 查看用户自定义的证书
     */
    function getOneUserCertTemp(address user, uint i) public view returns (string memory) {
        
        if(users[user].certTemps.length == 0)
            return "用户没有正在申请的证书";

        assert(i < 0 || i >= users[user].certTemps.length);
        return users[user].certTemps[i].name;
    }


    /** @dev 添加证书模板
     *  @param name 证书名称
     *  @return 返回证书模板的 id
     */
    function addCertTemps(string memory name) public returns(uint) {
        Certification memory certTemp;                  // 创建临时的证书
        certTemp.name = name;                           // 设置证书名称
        certTemps.push(certTemp);                       // 将证书模板存储到区块链中
        return certTemps.length - 1;
    }


    /** @dev 向组织中添加可以颁布的证书
     *  @param idOfOrg 组织的ID
     *  @param nameOfCertTemp 证书的名称
     *  @return 创建成功返回 true，否则返回 false
     */
    function addCertToOrg(uint idOfOrg, string memory nameOfCertTemp) public returns (bool) {

        uint idOfCert = addCertTemps(nameOfCertTemp);                       // 添加证书模板，并得到它的ID
        organizations[idOfOrg].typeOfCert[nameOfCertTemp] = idOfCert;       // 添加组织可以颁发的证书
        return true;
    }


    /** @dev 用户提交添加证书申请
     *  @param idOfCertTemp 证书模板的ID
     *  @param proof 检验证书真伪的信息
     *  @return 添加证书申请成功返回 ture，失败返回 false
     */
    function applyAddCert(uint idOfCertTemp, string memory proof) public returns(bool) {
        
        Certification memory cert = certTemps[idOfCertTemp];
        cert.proof = proof;
        users[msg.sender].applyingCerts.push(cert);
        // 还需要说明是哪个组织发放的
        return true;
    }


    /** @dev 根据索引撤销证书申请
     *  @return 撤销成功返回 true，否则返回 false
     */
    function repealAddCert() public returns(bool) {
        // 之后需要改成按照索引删除
        users[msg.sender].applyingCerts.pop();
        return true;
    }
    
}




