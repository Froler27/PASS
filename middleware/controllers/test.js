var getAccounts = async (ctx, next) => {
    var web3 = ctx.web3;
    // const abiAuth = [{"constant":false,"inputs":[{"name":"name","type":"string"}],"name":"createAccount","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x298daf5b"},{"constant":false,"inputs":[{"name":"name","type":"string"},{"name":"owners","type":"address[]"}],"name":"createOrganization","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x5523ab67"},{"constant":true,"inputs":[{"name":"user","type":"address"},{"name":"i","type":"uint256"}],"name":"getOneUserAcquiredCert","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function","signature":"0xf3b4dd66"},{"constant":true,"inputs":[{"name":"user","type":"address"},{"name":"i","type":"uint256"}],"name":"getOneUserApplyingCert","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function","signature":"0x3810cb84"},{"constant":true,"inputs":[{"name":"user","type":"address"},{"name":"i","type":"uint256"}],"name":"getOneUserCertTemp","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function","signature":"0xd19adbf9"},{"constant":false,"inputs":[{"name":"name","type":"string"}],"name":"addCertTemps","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0xeaa84d1e"},{"constant":false,"inputs":[{"name":"idOfOrg","type":"uint256"},{"name":"nameOfCertTemp","type":"string"}],"name":"addCertToOrg","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x7b6fa8f5"},{"constant":false,"inputs":[{"name":"idOfCertTemp","type":"uint256"},{"name":"proof","type":"string"}],"name":"applyAddCert","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x4dee9f94"},{"constant":false,"inputs":[],"name":"repealAddCert","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0xf4ecf4c2"}];
    // const addressAuth = '0xaF46C3783969B6FcA67e56D6457600Ef96089BC2';
    // var abiTT = [{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"setA","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"a","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getA","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}];
    // var addressTT = '0x296a3e7065fa80a549844bd554380b42eb6f9d89';
    // // var myContract = new web3.eth.Contract(abiAuth, addressAuth);
    // var contractTT = new web3.eth.Contract(abiTT, addressTT);
    // await contractTT.methods.getA().call().then(function (res) {
    //     console.log("++++++++++++++++++");
    //     console.log(res);

    // }).catch(function (reason) {
    //     console.log("===================");
    //     console.log(reason);
        
    // });
    // myContract.options.from = '0xf8972c13535184a8754cbd3dc95f68cf82641b51'; // default from address
    // myContract.options.gasPrice = '20000000000000'; // default gas price in wei
    // myContract.options.gas = 5000000; // provide as fallback always 5M gas

    // var res = myContract.methods.createAccount("LLL").call().
 
    var accounts = ["777777777777777777777"];

    await web3.eth.personal.getAccounts().then(function (accounts) {
        console.log('成功：' + accounts[0]);

        accounts = accounts.slice(0,3);

    }).catch(function (reason) {
        console.log('失败：' + reason);
        
        accounts = ['获取账户失败！'];
    });

    ctx.render('test.html', {
        title: 'TEST',
        accounts: accounts
    });

};


module.exports = {
    'GET /test': getAccounts
};