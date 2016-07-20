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
            //
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