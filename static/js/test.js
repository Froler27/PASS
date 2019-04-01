
function success(res) {
    res = JSON.parse(res);
    data.accounts = res.accounts;
}

function fail(code) {
    data.accounts = ["获取账户失败！"];
}

function getAccounts(){

    var request;
    if (window.XMLHttpRequest) {
        request = new XMLHttpRequest();
    } else {
        request = new ActiveXObject('Microsoft.XMLHTTP');
    }

    request.onreadystatechange = function () { // 状态发生变化时，函数被回调
        if (request.readyState === 4) { // 成功完成
            // 判断响应结果:
            if (request.status === 200) {
                // 成功，通过responseText拿到响应的文本:
                return success(request.responseText);
            } else {
                // 失败，根据响应码判断失败原因:
                return fail(request.status);
            }
        } else {
            // HTTP请求还在继续...
        }
    }

    // 发送请求:
    request.open('GET', '/api/accounts');
    request.send();

    alert('请求已发送，请等待响应...');
}

var data = {
    accounts: []
}

window.onload = function (){
    $('#nav-home').removeClass('active');
    $('#nav-test').addClass('active');
    const testApp = new Vue({
        el: '#divTest',
        data: data,
    
        delimiters: ['{[', ']}']
    })


    var btn = document.getElementById('btn');

    btn.addEventListener('click', getAccounts, false);
}
