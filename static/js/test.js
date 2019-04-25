
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

function ajaxLog(s) {
    var txt = $('#show');
    txt.text(txt.text() + '\n' + s);
}

function getA() {
    $.ajax("/api/a")
    .done(function(res) {
        ajaxLog(parseInt(res.a._hex));
        console.log(parseInt(res.a._hex));
    })
    .fail(function() {
        alert( "error" );
    })
    .always(function(res) {
        alert( "complete" +res.a);
    });
}

function setA() {
    $.ajax("/api/a")
    .done(function(res) {
        ajaxLog(parseInt(res.a._hex));
        console.log(parseInt(res.a._hex));
    })
    .fail(function() {
        alert( "error" );
    })
    .always(function(res) {
        alert( "complete" +res.a);
    });
}

function showError(resp) {
    resp.json().then(function (result) {
        console.log('Error: ' + result.message);
    });
}

var data = {
    accounts: [],
    a: "未取得"
}

// window.onload = function (){
// $(document).ready(function(){

const testApp = new Vue({
    el: '#divTest',
    data: data,
    delimiters: ['{[', ']}'],
    created: function (){
        this.init();
    },
    methods: {
        init: function (){
            var that = this;
            that.loading = true;
            console.log("--------initing-------");
            $('#nav-home').removeClass('active');
            $('#nav-test').addClass('active');
            that.loading = false;
            console.log("--------end init-------");
        },

        getA: function (){
            var that = this;
            
            that.$resource('/api/a').get().then(function (resp) {
                
                resp.json().then(function (result) {
                    that.a = parseInt(result.a._hex);
                });
            }, function (resp) {
                showError(resp);
            });
        },

        setA: function (newA, e) {
            var that = this;
            var t = {
                name: todo.name,
                description: todo.description
            };
            t[prop] = e.target.innerText;
            if (t[prop] === todo[prop]) {
                return;
            }
            that.$resource('/api/a').update(newA).then(function (resp) {
                resp.json().then(function (r) {
                    todo.name = r.name;
                    todo.description = r.description;
                });
            }, function (resp) {
                e.target.innerText = todo[prop];
                showError(resp);
            });
        }
    }
    
})



var btn = document.getElementById('btn');
//var btnJoin = document.getElementById('btn-join');

btn.addEventListener('click', getAccounts, false);
//btnJoin.addEventListener('click', getA, false);
//$('#btn-join').on('click', testApp.getA, false);
    
//});
