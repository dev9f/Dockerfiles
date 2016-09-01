var util = require('./util.js');

var servicesModule = (function() {
    var _private = {
        getServicesStatusList: function(req, res) {
            var servicestatus = req.query.servicestatus;
            var command = '/nagios/cgi-bin/statusjson.cgi?query=servicelist&details=true';
            if (util.isset(servicestatus)) {
                command += '&servicestatus=' + servicestatus;
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
        writeServiceConfig: function(req, res) {
            var payload = req.body.payload;
            if (util.isset(payload)) {
                var configs = util.make(payload, 'service');
                var config = '/app/nagios/etc/servers/services.cfg';
                util.write(config, configs, function(response) {
                    res.status(response.statusCode);
                    res.send({msg: response.statusMessage});
                });
            } else {
                res.status(400);
                res.send({msg: 'Invalid argument.'});
            }
        },
        getServiceStatusDetail: function(req, res) {
            var hostname = req.params.hostname;
            var servicedescription = req.query.servicedescription;
            if (util.isset(hostname) && util.isset(servicedescription)) {
                var command = '/nagios/cgi-bin/statusjson.cgi?query=service&hostname=' + hostname + '&servicedescription=' + servicedescription;

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
            _private.getServicesStatusList(req, res);
        },
        store: function(req, res) {
            _private.writeServiceConfig(req, res);
        },
        show: function(req, res) {
            _private.getServiceStatusDetail(req, res);
        }
    }
}());

module.exports = servicesModule;
