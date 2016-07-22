var express = require('express');
var router = express.Router();
var commandsModule = require('./commandsModule.js');
var hostsModule = require('./hostsModule.js');
var servicesModule = require('./servicesModule.js');
var nagiosModule = require('./nagiosModule.js');

router.use(function timeLog(req, res, next) {
    console.log('Time: ', new Date());
    console.log('URL: ', req.url);
    next();
});
router.get('/', function(req, res) {
    res.json({ message: 'Nagios API v1' });
});
router.post('/commands', function(req, res) {
    commandsModule.store(req, res);
});
router.get('/hosts', function(req, res) {
    hostsModule.index(req, res);
});
router.post('/hosts', function(req, res) {
    hostsModule.store(req, res);
});
router.get('/hosts/:id', function(req, res) {
    hostsModule.show(req, res);
});
router.get('/services', function(req, res) {
    servicesModule.index(req, res);
});
router.post('/services', function(req, res) {
    servicesModule.store(req, res);
});
router.get('/services/:id', function(req, res) {
    servicesModule.show(req, res);
});
router.get('/nagios', function(req, res) {
    nagiosModule.index(req, res);
});


var appRouter = function(app) {
    app.use('/api/v1', router);
};

module.exports = appRouter;