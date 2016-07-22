var util = require('./util.js');

var hostsModule = (function() {
    var _private = {
        getHostsStatusList: function(req, res) {
            var hoststatus = req.params.hoststatus;
            var command = '/nagios/cgi-bin/statusjson.cgi?query=hostlist&details=true';
            if (util.isset(hoststatus)) {
                command += '&hoststatus=' + hoststatus;
            }

            util.send(command, res);
        },
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

                    configs += 'define host{\n' + config + '}\n\n';
                }

                var config = '/app/nagios/api/test/hosts.cfg';
                util.write(config, configs, res);
            } else {
                res.status(400);
                res.send('Invalid argument.');
            }
        },
        getHostStatusDetail: function(req, res) {
            var hostname = req.params.hostname;
            if (util.isset(hostname)) {
                var command = '/nagios/cgi-bin/statusjson.cgi?query=host&hostname=' + hostname;

                util.send(command, res);
            } else {
                res.status(400);
                res.send('Invalid argument.');
            }
        }
    };
    return {
        index: function(req, res) {
            _private.getHostsStatusList(req, res);
        },
        store: function(req, res) {
            _private.writeHostConfig(req, res);
        },
        show: function(req, res) {
            _private.getHostStatusDetail(req, res);
        }
    }
}());

module.exports = hostsModule;