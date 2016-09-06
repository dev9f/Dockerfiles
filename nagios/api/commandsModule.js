var util = require('./util.js');

var commandsModule = (function() {
    var _private = {
        writeCommandConfig: function(req, res) {
            var payload = req.body.payload;
            if (util.isset(payload)) {
                var configs = util.make(payload, 'command');
                var config = '/app/nagios/etc/objects/commands.cfg';
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
            _private.writeCommandConfig(req, res);
        }
    }
}());

module.exports = commandsModule;
