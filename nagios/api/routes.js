var express = require('express');
var router = express.Router();
// var commandsModule = require('./commandsModule.js');
var hostsModule = require('./hostsModule.js');

router.use(function timeLog(req, res, next) {
    console.log('Time: ', new Date());
    console.log('URL: ', req.url);
    next();
});
router.get('/', function(req, res) {
    res.json({ message: 'Nagios API v1' });
});
// router.post('/commands', function(req, res) {
//     commandsModule.store();
// });
router.get('/hosts', function(req, res) {
    hostsModule.index(req, res);
});
router.post('/hosts', function(req, res) {
    hostsModule.store(req, res);
});
router.get('/hosts/:id', function(req, res) {
    hostsModule.show(req, res);
});

var appRouter = function(app) {
    app.use('/api/v1', router);
};

module.exports = appRouter;