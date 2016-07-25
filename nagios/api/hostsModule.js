var util = require('./util.js');

var hostsModule = (function() {
    var _private = {
        getHostsStatusList: function(req, res) {
            var hoststatus = req.params.hoststatus;
            var command = '/nagios/cgi-bin/statusjson.cgi?query=hostlist&details=true';
            if (util.isset(hoststatus)) {
                command += '&hoststatus=' + hoststatus;
            }

            util.send(command, function(response) {
                if (response.success) {
                    res.send(response.body);
                } else {
                    res.status(response.statusCode);
                    res.send({msg: response.statusMessage});
                }
            });
        },
        writeHostConfig: function(req, res) {
            var payload = req.body.payload;
            if (util.isset(payload)) {
                var configs = util.make(payload, 'host');
                var config = '/app/nagios/api/test/hosts.cfg';
                util.write(config, configs, function(response) {
                    res.status(response.statusCode);
                    res.send({msg: response.statusMessage});
                });
            } else {
                res.status(400);
                res.send({msg: 'Invalid argument.'});
            }
        },
        getHostStatusDetail: function(req, res) {
            var hostname = req.params.hostname;
            if (util.isset(hostname)) {
                var command = '/nagios/cgi-bin/statusjson.cgi?query=host&hostname=' + hostname;

                util.send(command, function(response) {
                    if (response.success) {
                        res.send(response.body);
                    } else {
                        res.status(response.statusCode);
                        res.send({msg: response.statusMessage});
                    }
                });
            } else {
                res.status(400);
                res.send({msg: 'Invalid argument.'});
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