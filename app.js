const Koa = require('koa');
// const Web3 = require('Web3');
const bodyParser = require('koa-bodyparser');
const controller = require('./middleware/controller');
const templating = require('./middleware/templating');
const rest = require('./middleware/rest');
const contracts = require('./middleware/contracts');

// 创建一个Koa对象表示web app本身:
const app = new Koa();

const isProduction = process.env.NODE_ENV === 'production';

// 记录URL以及页面执行时间：
app.use(async (ctx, next) => {
    console.log(`Process ${ctx.request.method} ${ctx.request.url}...`);
    var
        start = new Date().getTime(),
        execTime;
    await next();
    execTime = new Date().getTime() - start;
    ctx.response.set('X-Response-Time', `${execTime}ms`);
});

// 处理静态文件：
if (! isProduction) {
    let staticFiles = require('./middleware/static-files');
    app.use(staticFiles('/static/', __dirname + '/static'));
}

// 解析POST请求：
app.use(bodyParser());

// bind .rest() for ctx:
app.use(rest.restify());

// add nunjucks as view:
app.use(templating('views', {
    noCache: !isProduction,
    watch: !isProduction
}));

// 添加对智能合约的操作
app.use(contracts());

// 处理URL路由：
app.use(controller());

app.listen(3000);
console.log('app started at http://localhost:3000');