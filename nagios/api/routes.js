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
//     var result = commandsModule.store();
//     res.json(result);
// });
router.get('/hosts', function(req, res) {
    var result = hostsModule.index(req);
    res.json(result);
});
router.post('/hosts', function(req, res) {
    var result = hostsModule.store(req);
    res.json(result);
});
router.get('/hosts/:id', function(req, res) {
    var result = hostsModule.show(req);
    res.json(result);
});

var appRouter = function(app) {
    app.use('/api/v1', router);
};

module.exports = appRouter;