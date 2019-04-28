pragma solidity >=0.4.21 <0.7.0;

contract Organization{
    string name;
    address creator;
    address[] admins;
    address[] members;
    uint createTime;  

    string[] certs; 

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

    function getName() public view returns(string memory){
        return name;
    }

    function getCreator() public view returns(address){
        return creator;
    }

    function getAdmins() public view returns(address[] memory){
        return admins;
    }

    function getMembers() public view returns(address[] memory){
        return members;
    }

    function getCreatedTime() public view returns(uint){
        return createTime;
    }

    //------------------------------------------------------------

    function findAdmin(address admin) public view returns(uint){
        uint i;
        for(i=0; i<admins.length; i++)
            if(admin == admins[i])
                return i;
        return i;
    }

    function addAdmin(address admin) onlyCreator public {
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
    function deleteAdmin(address admin) onlyCreator public returns(bool){
        uint i = findAdmin(admin);
        require(
            i != admins.length,
            "This user is not admin!"
        );
        delete admins[i];
        return true;
    }

    //---------------------------------------------------------------

    function findMember(address member) public view returns(uint){
        uint i;
        for(i=0; i<members.length; i++)
            if(member == members[i])
                return i;
        return i;
    }

    function addMember(address member) onlyAdmin public{
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
    function deleteMember(address member) onlyAdmin public returns(bool){
        uint i = findMember(member);
        require(
            i != members.length,
            "This user is not member!"
        );
        delete members[i];
        return true;
    }

    //--------------------------------------

}