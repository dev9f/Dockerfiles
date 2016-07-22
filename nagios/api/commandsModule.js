var util = require('./util.js');

var commandsModule = (function() {
    var _private = {
        writeHostConfig: function(req, res) {
            var payload = req.body.payload;
            if (util.isset(payload)) {
                var configs = '';

                for (x in payload) {
                    var details = payload[x]['details'];
                    var config = '';

                    for (y in details) {
                        config += '\t' + y + '\t' + details[y] + '\n';
                    }

                    configs += 'define command{\n' + config + '}\n\n';
                }

                var config = '/app/nagios/api/test/commands.cfg';
                util.write(config, configs, res);
            } else {
                res.status(400);
                res.send('Invalid argument.');
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