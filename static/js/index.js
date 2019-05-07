function showError(resp) {
    resp.json().then(function (result) {
        console.log('Error: ' + result.message);
    });
}

const GAS = 6721975;

var vm = new Vue({
    el: '#body-div',
    data: {
        web3Provider: null,
        contracts: {},
        accounts: [],
        userAdr: "",
        user: {},
        nickName: "",
        realName: "",
        IDcardNum: "",
        personalWords: "",

        orgs: {
            amount: 0,
            orgNames: []
        }
    },

    delimiters: ['{[', ']}'],

    http: {
        timeout: 5000
    },

    created: function () {
        this.init();
    },

    methods: {
        init: async function () {
            $('#userNickName').popover('disable');
            
            return await this.initWeb3();
        },

        initWeb3: async function() {
            this.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:9545');
            console.info("连接到 http://127.0.0.1:9545");
            web3 = new Web3(this.web3Provider);
    
            return this.initContract();
        },

        initContract: function() {
            var that = this;

            web3.eth.getAccounts(function(error, accounts){
                if(error) {
                    console.log("----eor:" + error);
                }
                console.log(accounts);
                that.accounts = accounts;
            });

            $.getJSON('/static/PASS.json', function(data) {
                // Get the necessary contract artifact file and instantiate it with truffle-contract.
                var PASSArtifact = data;
                that.contracts.PASS = TruffleContract(PASSArtifact);
                
                // Set the provider for our contract.
                that.contracts.PASS.setProvider(that.web3Provider);
                

                // 初始化宠物领养信息
                //return App.markAdopted();
            });
        
            // 注册宠物领养事件
            //return that.bindEvents();
        },

        register: function () {
            var PASSInstance;
            var that = this;
            var $userNickName = $('#userNickName');
            if(! $userNickName.val().trim()){
                $userNickName.popover('enable').popover('show').focus();
                setTimeout(function () {
                    $userNickName.popover('hide').popover('disable');
                }, 2000);
            }else{
                console.log("正在注册...");

                that.contracts.PASS.deployed().then(function(instance) {
                    console.log('---------------1');
                    PASSInstance = instance;  // 获取智能合约对象
            
                    return PASSInstance.getSelfAdr();
                }).then(function(res) {
                    console.log(res);
                    that.userAdr = res;
                    that.user.nickName = $userNickName.val().trim();
                    that.user.personalWords = $('#personalWords').val();
                    that.user.realName = "未填写";
                    that.user.IDcardNum = "未填写";
                    return PASSInstance.register( JSON.stringify( that.user), {from: res, gas: GAS});
                }).then(function(res) {
                    console.log(res+'---------注册成功------2');
                    that.nickName = that.user.nickName;
                    that.personalWords = that.user.personalWords;
                    that.realName = that.user.realName;
                    that.IDcardNum = that.user.IDcardNum;
                    //$('#joinModal').modal('hide');
                    alert("注册成功！");
                    location.reload();
                }).catch(function(err) {
                    console.log('-------注册失败--------3');
                    console.log(err.message);
                    var $repeatRegisterAlert = $("#repeatRegisterAlert");
                    $repeatRegisterAlert.addClass('show');
                    setTimeout(function () {
                        $repeatRegisterAlert.removeClass('show');
                    }, 3000);
                });

                
            }
        },

        login: function () {
            console.log("正在登录...");

            var PASSInstance;
            var that = this;

            that.contracts.PASS.deployed().then(function(instance) {
                console.log('---------------1');

                PASSInstance = instance;  // 获取智能合约对象
        
                return PASSInstance.getSelfAdr();
            }).then(function(res) {
                console.log(res+'---------------2');

                that.userAdr = res;
                return PASSInstance.getUserinfo(res);
                
            }).then(function(res){
                if(!res)
                    alert("请先注册！");
                else{
                    that.user = JSON.parse(res);
                    that.nickName = that.user.nickName;
                    that.personalWords = that.user.personalWords;
                    if(that.user.realName){
                        that.realName = that.user.realName;
                        that.IDcardNum = that.user.IDcardNum;
                    }else{
                        that.realName = "未填写";
                        that.IDcardNum = "未填写";
                    }
                    
                    $('#divLoginOrJoin').remove();
                    $('#nav').removeClass('f-hide');
                    $('#left-nav-tab').removeClass('f-hide');
                    $('#divMain').removeClass('f-hide');
                }
            }).catch(function(err) {
                console.log('---------------3');
                console.log(err.message);
                //alert("请先在钱包上登录！");
                alert(err.message);
            });

            
            
        },


        create: function (todo) {
            var that = this;
            that.$resource('/api/todos').save(todo).then(function (resp) {
                resp.json().then(function (result) {
                    that.todos.push(result);
                });
            }, showError);
        },

        update: function (todo, prop, e) {
            var that = this;
            var t = {
                name: todo.name,
                description: todo.description
            };
            t[prop] = e.target.innerText;
            if (t[prop] === todo[prop]) {
                return;
            }
            that.$resource('/api/todos/' + todo.id).update(t).then(function (resp) {
                resp.json().then(function (r) {
                    todo.name = r.name;
                    todo.description = r.description;
                });
            }, function (resp) {
                e.target.innerText = todo[prop];
                showError(resp);
            });
        },

        remove: function (todo) {
            var that = this;
            that.$resource('/api/todos/' + todo.id).delete().then(function (resp) {
                var i, index = -1;
                for (i=0; i<that.todos.length; i++) {
                    if (that.todos[i].id === todo.id) {
                        index = i;
                        break;
                    }
                }
                if (index >= 0) {
                    that.todos.splice(index, 1);
                }
            }, showError);
        }

    }
});

window.vm = vm;

// var vmAdd = new Vue({
//     el: '#vmAdd',
//     data: {
//         name: '',
//         description: ''
//     },
//     methods: {
//         submit: function () {
//             vm.create(this.$data);
//             this.name = '';
//             this.description = '';
//         }
//     }
// });

