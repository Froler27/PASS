const App = new Vue({
    el: '#_test',
    data: {
        web3Provider: null,
        contracts: {},
        realName: 'none'
    },
    delimiters: ['{[', ']}'],
    created: function (){
        this.init();
    },
    
    methods: {
        init: async function() {
        //$.getJSON('../pets.json', function(data) { });
    
            return await this.initWeb3();
        },
    
        initWeb3: async function() {
            // Initialize web3 and set the provider to the testRPC.
            // if (typeof web3 !== 'undefined') {
            //     this.web3Provider = web3.currentProvider;
            //     // froler
            //     console.info("连接到已有的链！");
            // } else {
                // set the provider you want from Web3.providers
                this.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:9545');
                console.info("连接到 http://127.0.0.1:9545");
            // }
            web3 = new Web3(this.web3Provider);
    
            return this.initContract();
        },
    
        // 此函数用来加载智能合约的json文件
        initContract: function() {
            var that = this;
            $.getJSON('/static/PASS.json', function(data) {
                // Get the necessary contract artifact file and instantiate it with truffle-contract.
                var PASSArtifact = data;
                that.contracts.PASS = TruffleContract(PASSArtifact);
                
                // Set the provider for our contract.
                that.contracts.PASS.setProvider(that.web3Provider);
                console.log(that.web3Provider);
                web3.eth.getAccounts(function(error, accounts){
                    if(error) {
                        console.log(error);
                    }
                    var account = accounts[0];
                    console.info(account);
                });
                // 初始化宠物领养信息
                //return App.markAdopted();
            });
        
            // 注册宠物领养事件
            return that.bindEvents();
        },
    
        bindEvents: function() {
            //$(document).on('click', '.btn-adopt', App.handleAdopt);
        },

        register: function() {
            var PASSInstance;
            var that = this;
            console.log(that.contracts);
            that.contracts.PASS.deployed().then(function(instance) {
                console.log('---------------1');
                PASSInstance = instance;  // 获取智能合约对象
        
                console.log(instance + '-------------------');
                return PASSInstance.register("Froler");
                // return adoptionInstance.transfer(toAddress, amount, {from: account, gas: 100000});
            }).then(function(res) {
                console.log(res+'---------------2');
                that.realName = res;
            }).catch(function(err) {
                console.log('---------------3');
                console.log(err.message);
            });
        },
        
        getName: function() {
            var PASSInstance;
            var that = this;
            console.log(that.contracts);
            that.contracts.PASS.deployed().then(function(instance) {
                console.log('---------------1');
                PASSInstance = instance;  // 获取智能合约对象
        
                // 调用领养的方法，主要实现宠物领养的功能
                console.log(instance + '-------------------');
                return PASSInstance.test();
                // return adoptionInstance.transfer(toAddress, amount, {from: account, gas: 100000});
            }).then(function(res) {
                console.log(res+'---------------2');
                that.realName = res;
            }).catch(function(err) {
                console.log('---------------3');
                console.log(err.message);
            });
        
        
            console.info("getName........");
        },
        
        markAdopted: function(adopters, account) {
            
            var PASSInstance;
            var that = this;
        
            that.contracts.PASS.deployed().then(function(instance) {
                PASSInstance = instance;  // 获取智能合约对象
        
                // 调用领养的方法，主要实现宠物领养的功能
                return PASSInstance.getAdopters();
                // return adoptionInstance.transfer(toAddress, amount, {from: account, gas: 100000});
            }).then(function(adopters) {
                // 2. 根据穷无被领养的状态，来修改按钮。
                for(i = 0; i < adopters.length; i++){
                    if(adopters[i] != "0x0000000000000000000000000000000000000000"){
                        // 说明当前宠物已经被领养，只需要修改按钮状态即可
                        $(".panel-pet").eq(i).find('button').text("success").attr("disabled", true);
                    }
                }
                //return App.getBalances();
            }).catch(function(err) {
                console.log(err.message);
            });
        
        
            console.info("markAdopted........");
        }
        
        // handleAdopt: function(event) {
        //     event.preventDefault();
        
        //     var petId = parseInt($(event.target).data('id'));

        
        //     // 2. 实例化智能合约
        
        //     var adoptionInstance;  // 声明存储智能合约的实例的变量
        //     // 通过异步方式获取当前测试账户
        //     App.contracts.Adoption.deployed().then(function(instance) {
        //         adoptionInstance = instance;  // 获取智能合约对象
        //         console.info("adoptionInstance--->" + adoptionInstance);
        //         // 如果不添加：{from: account}则需要钱包来测试
        //         return adoptionInstance.adopt(petId);
        //         // return adoptionInstance.transfer(toAddress, amount, {from: account, gas: 100000});
        //     }).then(function(result) {
        //         console.info(result);
        //         // 修改按钮状态
        //         return App.markAdopted();
        //         //return App.getBalances();
        //     }).catch(function(err) {
        //         console.log(err.message);
        //     });
        // }
    }
  
});
  
//   $(function() {
//     $(window).load(function() {
//       App.init();
//     });
//   });
  