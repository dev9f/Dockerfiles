var express = require('express');
var router = express.Router();

router.use(function timeLog(req, res, next) {
    console.log('Time: ', Date.now());
    next();
});
router.get('/', function(req, res) {
    res.json({ message: 'routes.js router get /' });
});
router.route('/about')
    .get(function(req, res) {
        res.json({ message: 'routes.js router route /about get' });
    });

var appRouter = function(app) {
    app.use('/api', router);
};

module.exports = appRouter;