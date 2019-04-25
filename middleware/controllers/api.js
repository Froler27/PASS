const APIError = require('../rest').APIError;

var gid = 0;

function nextId() {
    gid ++;
    return 't' + gid;
}

var todos = [
    {
        id: nextId(),
        name: 'Learn Git',
        description: 'Learn how to use git as distributed version control'
    },
    {
        id: nextId(),
        name: 'Learn JavaScript',
        description: 'Learn JavaScript, Node.js, NPM and other libraries'
    },
    {
        id: nextId(),
        name: 'Learn Python',
        description: 'Learn Python, WSGI, asyncio and NumPy'
    },
    {
        id: nextId(),
        name: 'Learn Java',
        description: 'Learn Java, Servlet, Maven and Spring'
    }
];

module.exports = {
    'GET /api/accounts': async (ctx, next) => {
        var accounts = await ctx.web3.eth.personal.getAccounts();
        ctx.rest({
            accounts: accounts
        });
    },

    'GET /api/a': async (ctx, next) => {
        var abiTT = [{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"setA","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"a","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getA","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}];
        var addressTT = '0x296a3e7065fa80a549844bd554380b42eb6f9d89';
        // var myContract = new web3.eth.Contract(abiAuth, addressAuth);
        var contractTT = new ctx.web3.eth.Contract(abiTT, addressTT);
        var a = await contractTT.methods.getA().call()//.then(function (res) {
        //     console.log("++++++++++++++++++");
        //     console.log(res);
        // }).catch(function (reason) {
        //     console.log("===================");
        //     console.log(reason);
        // });
        ctx.rest({
            a: a
        });
    },

    'PUT /api/a': async (ctx, next) => {
        var
            newA = ctx.request.body,
            index = -1,
            i, todo;
        if (!newA || ! isNaN(newA)) {
            throw new APIError('invalid_input', 'Missing Number');
        }
        var res = await contractTT.methods.setA().send();
        ctx.rest({
            res: res
        });
    },

    'GET /api/todos': async (ctx, next) => {
        ctx.rest({
            todos: todos
        });
    },

    'POST /api/todos': async (ctx, next) => {
        var
            t = ctx.request.body,
            todo;
        if (!t.name || !t.name.trim()) {
            throw new APIError('invalid_input', 'Missing name');
        }
        if (!t.description || !t.description.trim()) {
            throw new APIError('invalid_input', 'Missing description');
        }
        todo = {
            id: nextId(),
            name: t.name.trim(),
            description: t.description.trim()
        };
        todos.push(todo);
        ctx.rest(todo);
    },

    'PUT /api/todos/:id': async (ctx, next) => {
        var
            t = ctx.request.body,
            index = -1,
            i, todo;
        if (!t.name || !t.name.trim()) {
            throw new APIError('invalid_input', 'Missing name');
        }
        if (!t.description || !t.description.trim()) {
            throw new APIError('invalid_input', 'Missing description');
        }
        for (i=0; i<todos.length; i++) {
            if (todos[i].id === ctx.params.id) {
                index = i;
                break;
            }
        }
        if (index === -1) {
            throw new APIError('notfound', 'Todo not found by id: ' + ctx.params.id);
        }
        todo = todos[index];
        todo.name = t.name.trim();
        todo.description = t.description.trim();
        ctx.rest(todo);
    },

    'DELETE /api/todos/:id': async (ctx, next) => {
        var i, index = -1;
        for (i=0; i<todos.length; i++) {
            if (todos[i].id === ctx.params.id) {
                index = i;
                break;
            }
        }
        if (index === -1) {
            throw new APIError('notfound', 'Todo not found by id: ' + ctx.params.id);
        }
        ctx.rest(todos.splice(index, 1)[0]);
    }
}