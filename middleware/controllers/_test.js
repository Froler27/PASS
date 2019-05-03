var fn_test = async (ctx, next) => {
    ctx.render('_test.html', {
        title: '测试'
    });
};


module.exports = {
    'GET /_test': fn_test
};