function showError(resp) {
    resp.json().then(function (result) {
        console.log('Error: ' + result.message);
    });
}

var vm = new Vue({
    el: '#body-div',
    delimiters: ['{[', ']}'],

    http: {
        timeout: 5000
    },

    data: {
        show_login_or_join: true,
        show_left_nav: false,
        show_main: false,
        show_nav:false,
        loading: false
    },

    created: function () {
        this.init();
    },

    methods: {
        init: function () {
            var that = this;
            that.$resource('/api/todos').get().then(function (resp) {
                that.loading = false;
                // 调用API成功时调用json()异步返回结果:
                resp.json().then(function (result) {
                    // 更新VM的todos:
                    that.todos = result.todos;
                });
            }, function (resp) {
                that.loading = false;
                // 调用API失败:
                // alert('error');
                showError(resp);
            });
            $('#userName').popover('disable');
        },

        join: function () {
            var $userName = $('#userName');
            if(! $userName.val().trim()){
                $userName.popover('enable').popover('show').focus();
                setTimeout(function () {
                    $userName.popover('hide').popover('disable');
                }, 2000);
            }else{
                console.log("正在注册...");
                $('#joinModal').modal('hide');
                $('#divLoginOrJoin').addClass('f-hide');
                $('#nav').removeClass('f-hide');
                $('#left-nav-tab').removeClass('f-hide');
                $('#divMain').removeClass('f-hide');
            }
        },

        login: function () {
            console.log("正在登录...");
            $('#divLoginOrJoin').addClass('f-hide');
            $('#nav').removeClass('f-hide');
            $('#left-nav-tab').removeClass('f-hide');
            $('#divMain').removeClass('f-hide');
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

