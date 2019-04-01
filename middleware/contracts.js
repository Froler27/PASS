const Web3 = require('Web3');

// const web3 = new Web3('http://localhost:8545');

// // or
// const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));

// // change provider
// web3.setProvider('ws://localhost:8546');
// // or
// web3.setProvider(new Web3.providers.WebsocketProvider('ws://localhost:8546'));

function contracts(){
    // 设置连接的区块链结点
    var web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:9545');
    console.log("连接到区块链节点：" + 'http://127.0.0.1:9545');
    console.log(web3Provider);
    // 创建 web3 对象
    var web3 = new Web3(web3Provider);

    return async (ctx, next) => {
        ctx.web3 = web3;
        await next();
    };
}

module.exports = contracts;




// async function awaitDemo(x) {
//     await normalFunc();
//     var i = x;
//     while(i>0){
//         i--;
//         console.log("---------------");
//     }
    
//     console.log('something, ~~');
//     let result = await sleep(2000).then(x => console.log("77777---" + x));
//     while(x>0){
//         x--;
//         console.log("*************");
//     }
//     console.log(result);// 两秒之后会被打印出来
// }


// function sleep(second, n) {
//     console.log("work-----" + n);
//     return new Promise((resolve, reject) => {
//         setTimeout(() => {
//             resolve(' enough sleep~' + n);
//         }, second);
//     })
// }

// async function bugDemo() {
//     console.log("begin----");
//     await sleep(1000, 1).then(console.log);
//     console.log("end-----1");
//     await sleep(5000, 2).then(console.log);
//     console.log("end-----2");
//     await sleep(1000, 3).then(console.log);
//     console.log("end-----3");
//     console.log('clear the loading~');
// }