var express = require('express');
var router = express.Router();
var contactsModule = require('./contactsModule.js');
var commandsModule = require('./commandsModule.js');
var timeperiodsModule = require('./timeperiodsModule.js');
var hostsModule = require('./hostsModule.js');
var servicesModule = require('./servicesModule.js');
var nagiosModule = require('./nagiosModule.js');
var statisticModule = require('./statisticModule.js');

router.use(function timeLog(req, res, next) {
    console.log('Time: ', new Date());
    console.log('URL: ', req.url);
    next();
});
router.get('/', function(req, res) {
    res.json({ message: 'Nagios API v1' });
});
router.post('/contacts', function(req, res) {
    contactsModule.store(req, res);
});
router.post('/commands', function(req, res) {
    commandsModule.store(req, res);
});
router.post('/timeperiods', function(req, res) {
    timeperiodsModule.store(req, res);
});
router.get('/hosts', function(req, res) {
    hostsModule.index(req, res);
});
router.post('/hosts', function(req, res) {
    hostsModule.store(req, res);
});
router.get('/hosts/:hostname', function(req, res) {
    hostsModule.show(req, res);
});
router.get('/services', function(req, res) {
    servicesModule.index(req, res);
});
router.post('/services', function(req, res) {
    servicesModule.store(req, res);
});
router.get('/services/:hostname', function(req, res) {
    servicesModule.show(req, res);
});
router.get('/nagios', function(req, res) {
    nagiosModule.index(req, res);
});
router.get('/statistic/:id', function(req, res) {
    statisticModule.show(req, res);
});


var appRouter = function(app) {
    app.use('/api/v1', router);
};

module.exports = appRouter;
