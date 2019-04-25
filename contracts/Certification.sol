pragma solidity >=0.4.21 <0.7.0;

contract Certification{
    string name;
    string body;
    
    address owner;
    address recipient;
    uint receiptTime;   // 获得证书的时间
    uint overdueTime;   // 证书的有效期限
    uint recordTime;    // 证书收录到平台的时间

    constructor(
        string memory _name, 
        string memory _body, 
        address _owner,
        address _recipient,
        uint _receiptTime,
        uint _overdueTime
    ) public{
        name = _name;
        body = _body;
        owner = _owner;
        recipient = _recipient;
        receiptTime = _receiptTime;
        overdueTime = _overdueTime;
        recordTime = now;
    }
}