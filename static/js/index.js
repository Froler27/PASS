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
        showOrgDetail: false,
        i: 0,
        user: {},
        userAdr: "",
        nickName: "",
        realName: "",
        IDcardNum: "",
        personalWords: "",

        issueCertOrg: "",

        showOrg: [],
        showCertName: [],

        ownOrgs: [
            // {
            //     name: "",
            //     createdTime: Date.now(),
            //     brief: "",
            //     creator: "",
            //     creatorName: "",
            //     admins: [],
            //     members: [],
            //     certs: [],
            //     issueCertIDs: [],
            //     applyCertIDs: []
            // }
        ],
        adminOrgs: [],
        memberOrgs: [],

        ownCerts: [],
        applyCerts: [],
        pendingCerts: [],

        invIDs: []
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

        login: async function () {
            console.log("正在登录...    时间：" + new Date());

            var PASSInstance;
            var that = this;

            await vm.contracts.PASS.deployed().then(function(instance) {
                console.log("success: " + new Date() + " -->: get PASS instance success!");

                PASSInstance = instance;  // 获取智能合约对象
        
                return PASSInstance.getSelfAdr();
            }).then(function(res) {
                console.log("success: " + new Date() + " -->: get user address: " + res);

                that.userAdr = res;
                return PASSInstance.getUserinfo(res);
                
            }).then(function(res){
                if(!res){
                    console.log("fail   : " + new Date() + " -->: 登录失败！");
                    alert("请先注册！");
                }
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

            await PASSInstance.getUserUintArr(vm.userAdr, 4).then(function(res){
                console.log("success: " + new Date() + " -->: get ownCerts success!");
                vm.ownCerts = res;
            }).catch(function(err) {
                console.log("fail   : " + new Date() + " -->: get ownCerts fail!");
                console.log(err.message);
                vm.ownCerts = [];
            });

            await PASSInstance.getUserUintArr(vm.userAdr, 1).then(function(res){
                console.log("success: " + new Date() + " -->: get ownOrgs success!");
                
                res.forEach(function (element){
                    vm.getOrgInfo(1, element);
                });
            }).catch(function(err) {
                console.log("fail   : " + new Date() + " -->: get ownOrgs fail!");
                console.log(err.message);
                vm.ownOrgs = [];
            });

            PASSInstance.getUserUintArr(vm.userAdr, 2).then(function(res){
                console.log("success: " + new Date() + " -->: get adminOrgs success!");
                vm.adminOrgs = res;
            }).catch(function(err) {
                console.log("fail   : " + new Date() + " -->: get adminOrgs fail!");
                console.log(err.message);
                vm.adminOrgs = [];
            });

            PASSInstance.getUserUintArr(vm.userAdr, 3).then(function(res){
                console.log("success: " + new Date() + " -->: get memberOrgs success!");
                vm.memberOrgs = res;
            }).catch(function(err) {
                console.log("fail   : " + new Date() + " -->: get memberOrgs fail!");
                console.log(err.message);
                vm.memberOrgs = [];
            });

            PASSInstance.getUserUintArr(vm.userAdr, 5).then(function(res){
                console.log("success: " + new Date() + " -->: get applyCerts success!");
                vm.applyCerts = res;
            }).catch(function(err) {
                console.log("fail   : " + new Date() + " -->: get applyCerts fail!");
                console.log(err.message);
                vm.applyCerts = [];
            });

            PASSInstance.getUserUintArr(vm.userAdr, 6).then(function(res){
                console.log("success: " + new Date() + " -->: get pendingCerts success!");
                vm.pendingCerts = res;
            }).catch(function(err) {
                console.log("fail   : " + new Date() + " -->: get pendingCerts fail!");
                console.log(err.message);
                vm.pendingCerts = [];
            });
        },

        createOrg: function(){
            var PASSInstance;
            var that = this;
            var $orgName = $('#orgName');
            var orginfo = {};
            
            if(! $orgName.val().trim()){
                $orgName.popover('enable').popover('show').focus();
                setTimeout(function () {
                    $orgName.popover('hide').popover('disable');
                }, 2000);
            }else{
                vm.contracts.PASS.deployed().then(function(instance) {
                    console.log("success: " + new Date() + " -->: get PASS instance success!");

                    PASSInstance = instance;  // 获取智能合约对象
                    
                    orginfo.name = $orgName.val().trim();
                    orginfo.createdTime = Date.now();
                    orginfo.creator = vm.userAdr;
                    orginfo.creatorName = vm.nickName;
                    orginfo.brief = $('#orgBrief').val();
                    
                    return PASSInstance.createOrg(orginfo.name, JSON.stringify(orginfo), {from: vm.userAdr, gas: GAS});
                }).then(function(orgID){
                    console.log("success: " + new Date() + " -->: create org success!");

                    // var d = new Date(orginfo.createdTime);
                    // orginfo.value = orgID;
                    // orginfo.createdDate = d.getFullYear() + " 年 " + (d.getMonth() + 1) + " 月 " + d.getDate() + " 日";
                    // orginfo.header = "header_own_" + orgID;
                    // orginfo.btnShow = "#collapse_own_" + orgID;
                    // orginfo.collapse = "collapse_own_" + orgID;
                    
                    // vm.ownOrgs.push(orginfo);
                    console.log(orgID);
                    vm.getOrgInfo(1, orgID);
                    
                    alert("创建组织成功！");
                    $('#createOrgModal').modal('hide');
                }).catch(function(err) {
                    console.log("fail: " + new Date() + " -->: create org fail!");
                    console.log(err.message);

                    alert("创建组织失败！\n错误信息：\n" + err.message);
                });
            }
        },

        getOrgInfo: async function (choice, orgID) {
            // console.log("正在登录...    时间：" + new Date());

            var PASSInstance;

            vm.contracts.PASS.deployed().then(function(instance) {
                console.log("success: " + new Date() + " -->: getOrgInfo gets PASS instance success!");

                PASSInstance = instance;  // 获取智能合约对象
        
                return PASSInstance.getOrginfo(0, orgID, "");
            }).then(function(res) {
                console.log("success: " + new Date() + " -->: get orginfo success!");
                console.log(res);
                var org = JSON.parse(res);
                var d = new Date(org.createdTime);
                org.value = orgID;
                org.createdDate = d.getFullYear() + " 年 " + (d.getMonth() + 1) + " 月 " + d.getDate() + " 日";
                if(choice === 1){
                    org.header = "header_own_" + orgID;
                    org.btnShow = "#collapse_own_" + orgID;
                    org.collapse = "collapse_own_" + orgID;
                    vm.ownOrgs.push(org);
                }
                else if(choice === 2){
                    org.header = "header_admin_" + orgID;
                    org.btnShow = "#collapse_admin_" + orgID;
                    org.collapse = "collapse_admin_" + orgID;
                    org.createdTime
                    vm.adminOrgs.push(org);
                }
                else if(choice === 3){
                    org.header = "header_member_" + orgID;
                    org.btnShow = "#collapse_member_" + orgID;
                    org.collapse = "collapse_member_" + orgID;
                    vm.memberOrgs.push(org);
                }
                
            }).catch(function(err) {
                console.log("fail   : " + new Date() + " -->: get orginfo fail!");
                console.log(err.message);
            });
        },

        showOrgs: function(){
            var $myOrgs = $('#my_orgs');
            var $myOrg = $('#my_org');
            if($myOrgs.hasClass('f-hide')){
                $myOrgs.removeClass("f-hide");
                $myOrg.addClass("f-hide");
            }
        },

        showOrgPage: async function(event) {
            vm.showOrgDetail = false;
            var PASSInstance;
            $('#my_orgs').addClass("f-hide");
            $('#my_org').removeClass("f-hide");
            var orgID = event.target.value;
            var orgName = $(event.target).next().text();
            var i=0;
            for (i=0; i<vm.ownOrgs.length; i++) {
                if(vm.ownOrgs[i].name == orgName){
                    break;
                }
            }
            
            await vm.contracts.PASS.deployed().then(function(instance) {
                console.log("success: " + new Date() + " -->: get PASS instance success!");

                PASSInstance = instance;  
                
                return PASSInstance.getOrgUserAdrs(1, orgName);
                
            }).then(function(res){
                console.log("success: " + new Date() + " -->: get org admins success!");
                vm.ownOrgs[i].admins = res;

                return PASSInstance.getOrgUserAdrs(2, orgName);
            }).then(function(res){
                console.log("success: " + new Date() + " -->: get org members success!");
                vm.ownOrgs[i].members = res;

                return PASSInstance.getOrgCertIDs(1, orgName);
            }).then(function(res){
                console.log("success: " + new Date() + " -->: get org issued certs' ID success!");
                vm.ownOrgs[i].issueCertIDs = res;

                return PASSInstance.getOrgCertIDs(2, orgName);
            }).then(function(res){
                console.log("success: " + new Date() + " -->: get org apply certs' ID success!");
                vm.ownOrgs[i].applyCertIDs = res;

                $("#orgPage").html(function(){
                    var htmlstr = '<h3>'+vm.ownOrgs[i].name +
                        '</h3><p>组织创建者名称：' + vm.ownOrgs[i].creatorName + 
                        '</p><p>组织创建者地址：' + vm.ownOrgs[i].creator + '</p>';
                    htmlstr += `<p>组织简介：` + vm.ownOrgs[i].brief + `</p> `;
                    return htmlstr;
                });
                vm.issueCertOrg = vm.ownOrgs[i].name;
                vm.showOrg.push(JSON.parse(JSON.stringify(vm.ownOrgs[i])));
                vm.showOrgDetail = true;
            }).catch(function(err) {
                console.log("fail: " + new Date() + " -->: get org detail fail!");
                console.log(err.message);

                alert("显示组织页面失败！\n错误信息：\n" + err.message);
            });

            var j;
            var n = 8;
            vm.i = 0;
            vm.showCertName = [];
            for(j=0; j<n; j++){
                await PASSInstance.getOrginfo(1, j, orgName).then(function(res){
                    
                    if(res.trim()){
                        vm.i += 1;
                        var obj = JSON.parse(res);
                        obj.i = vm.i;
                        vm.showCertName.push(obj);
                    }
                }).catch(function(err){
                    if(err.message=="VM Exception while processing transaction: invalid opcode")
                        j=n;
                    else{
                        console.log("fail: " + new Date() + " -->: get org cert fail!");
                        console.log(err.message);
                    }
                });
            }
        },

        addCertName: function(){
            var PASSInstance;
            var orgName = $('#orgPage>h3').text();
            var $certAdd = $('#certNameAdd');
            var certName = $certAdd.val().trim();
            var certType = $('#certTypeAdd').val().trim();
            var certAddObj = {};
            certAddObj.certName = certName;
            certAddObj.certType = certType;
            vm.showOrgDetail = false;
            console.log(certAddObj);

            for (const cert of vm.showCertName) {
                if(certName == cert.certName){
                    certName = '';
                    break;
                }
            }
            if(certName == ''){
                $certAdd.popover('enable').popover('show').focus();
                setTimeout(function () {
                    $certAdd.popover('hide').popover('disable');
                }, 2000);
            }else{
                vm.contracts.PASS.deployed().then(function(instance) {
                    console.log("success: " + new Date() + " -->: addCertName gets PASS instance success!");

                    PASSInstance = instance;  // 获取智能合约对象
            
                    return PASSInstance.opOrgCertName(1, orgName, JSON.stringify(certAddObj), 0, { gas: GAS});
                }).then(function(res) {
                    console.log("success: " + new Date() + " -->: add cert success!");
                    vm.i += 1;
                    certAddObj.i = vm.i;
                    vm.showCertName.push(certAddObj);
                    alert("添加可颁发证书成功！");
                    $('#addCertNameModal').modal('hide');
                }).catch(function(err) {
                    console.log("fail   : " + new Date() + " -->: add cert fail!");
                    console.log(err.message);
                });
            }
            vm.showOrgDetail = true;
        },

        changIssueCertName: function(e){
            var $e = $(e.target);
            console.log($e.attr('value'));
            $('#certNameIssue').val($e.attr('value'));

            var certType = $e.parent().prev().text();
            $('#certTypeIssue').val(certType);
            console.log(certType);
        },

        issueCert: function(){
            
            var PASSInstance;

            var certName = $('#certNameIssue').val();
            var certType =  $('#certTypeIssue').val();
            var $certGainer = $('#certGainer');
            var certGainer = $certGainer.val().trim();
            var certContent = $('#certContentIssue').val();
            var certIssueObj = {};

            certIssueObj.certName = certName;
            certIssueObj.certType = certType;
            certIssueObj.origin = vm.issueCertOrg;
            certIssueObj.issueTime = Date.now();
            certIssueObj.owner = certGainer;
            certIssueObj.sender = vm.userAdr;
            certIssueObj.certContent = certContent;

            var certObj = {};
            certObj.certName = certName;
            certObj.certType = certType;

            console.log(certIssueObj);

            var tag = false;
            for (const account of vm.accounts) {
                if(account == certGainer){
                    tag = true;
                    break;
                }
            }
            
            

            if(certGainer == '' || !tag){
                $certGainer.popover('enable').popover('show').focus();
                setTimeout(function () {
                    $certGainer.popover('hide').popover('disable');
                }, 2000);
            }else{
                vm.contracts.PASS.deployed().then(function(instance) {
                    console.log("success: " + new Date() + " -->: issueCert gets PASS instance success!");

                    PASSInstance = instance;  // 获取智能合约对象
            
                    return PASSInstance.orgIACert(1, JSON.stringify(certObj), JSON.stringify(certIssueObj), certGainer, vm.issueCertOrg, { gas: GAS});
                }).then(function(res) {
                    console.log("success: " + new Date() + " -->: issue cert success!");
                    
                    alert("证书颁发成功，等待用户接受！");
                    $('#issueCertModal').modal('hide');
                }).catch(function(err) {
                    console.log("fail   : " + new Date() + " -->: issue cert fail!");
                    console.log(err.message);
                    alert("证书颁发失败！\n错误信息如下：\n"+  err.message);
                });
            }
            
        },

        getPendingCerts: function(){
            
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

