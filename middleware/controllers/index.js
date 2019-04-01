var fn_index = async (ctx, next) => {
    ctx.render('index.html', {
        title: 'PASS'
    });
};


module.exports = {
    'GET /': fn_index
};