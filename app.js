
const Koa = require('koa');
const bodyParser = require('koa-bodyparser');
const controller = require('./controller');

// 创建一个Koa对象表示web app本身:
const app = new Koa();


// log request URL:
app.use(async (ctx, next) => {
    console.log(`Process ${ctx.request.method} ${ctx.request.url}...`);
    await next();
});

// 使用middleware:
app.use(bodyParser());
app.use(controller());

app.listen(3000);
console.log('app started at http://localhost:3000');