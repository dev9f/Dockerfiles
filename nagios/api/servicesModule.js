var util = require('./util.js');

var servicesModule = (function() {
    var _private = {
        getServicesStatusList: function(req, res) {
            var servicestatus = req.params.servicestatus;
            var command = '/nagios/cgi-bin/statusjson.cgi?query=servicelist&details=true';
            if (util.isset(servicestatus)) {
                command += '&servicestatus=' + servicestatus;
            }

            util.send(command, res);
        },
        writeServiceConfig: function(req, res) {
            var payload = req.body.payload;
            if (util.isset(payload)) {
                var configs = '';

                for (x in payload) {
                    var details = payload[x]['details'];
                    var config = '';

                    for (y in details) {
                        config += '\t' + y + '\t' + details[y] + '\n';
                    }

                    configs += 'define service{\n' + config + '}\n\n';
                }

                var config = '/app/nagios/api/test/services.cfg';
                util.write(config, configs, res);
            } else {
                res.status(400);
                return res.send('Invalid argument.');
            }
        },
        getServiceStatusDetail: function(req, res) {
            var hostname = req.params.hostname;
            var servicedescription = req.params.servicedescription;
            if (util.isset(hostname) && util.isset(servicedescription)) {
                var command = '/nagios/cgi-bin/statusjson.cgi?query=service&hostname=' + hostname + '&servicedescription=' + servicedescription;

                util.send(command, res);
            } else {
                res.status(400);
                return res.send('Invalid argument.');
            }
        }
    };
    return {
        index: function(req, res) {
            _private.getServicesStatusList(req, res);
        },
        store: function(req, res) {
            return _private.writeServiceConfig(req, res);
        },
        show: function(req, res) {
            _private.getServiceStatusDetail(req, res);
        }
    }
}());

module.exports = servicesModule;