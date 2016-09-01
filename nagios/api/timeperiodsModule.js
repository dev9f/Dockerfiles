var util = require('./util.js');

var timeperiodsModule = (function() {
    var _private = {
        writeTimeperiodConfig: function(req, res) {
            var payload = req.body.payload;
            if (util.isset(payload)) {
                var configs = util.make(payload, 'timeperiod');
                var config = '/app/nagios/etc/servers/timeperiods.cfg';
                util.write(config, configs, function(response) {
                    res.status(response.statusCode);
                    res.send({msg: response.statusMessage});
                });
            } else {
                res.status(400);
                res.send({msg: 'Invalid argument.'});
            }
        }
    };
    return {
        store: function(req, res) {
            _private.writeTimeperiodConfig(req, res);
        }
    }
}());

module.exports = timeperiodsModule;
