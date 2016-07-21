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
                // console.log('configs: \n' + configs);
                
                // delete host.cfg file
                var config = '/app/nagios/api/test';
                util.delete(config);

                // save host.cfg file
            } else {
                // return '400 error Invalid argument';
            }
        },
        getHostStatusDetail: function(req, res) {
            //
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