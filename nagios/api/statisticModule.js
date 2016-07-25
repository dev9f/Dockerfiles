var util = require('./util.js');

var statisticModule = (function() {
    var _private = {
        getStatusForDashboard: function(req, res) {
            var id = req.params.id;
            if (util.isset(id)) {
                switch (id) {
                    case 'host':
                        var command = '/nagios/cgi-bin/statusjson.cgi?query=hostcount&hoststatus=up+down+unreachable+pending';
                        util.send(command, function(response) {
                            if (response.success) {
                                var result = JSON.parse(response.body);
                                var count = result.data.count;
                                var counts = 0;
                                for (i in count) counts += count[i];
                                result.data.count.types = counts;
                                result.data.count.problems = result.data.count.unreachable + result.data.count.down;
                                res.send(result);
                            } else {
                                res.status(response.statusCode);
                                res.send({msg: response.statusMessage});
                            }
                        });
                        break;
                    case 'service':
                        var command = '/nagios/cgi-bin/statusjson.cgi?query=servicecount&servicestatus=ok+warning+critical+unknown+pending';
                        util.send(command, function(response) {
                            if (response.success) {
                                var result = JSON.parse(response.body);
                                var count = result.data.count;
                                var counts = 0;
                                for (i in count) counts += count[i];
                                result.data.count.types = counts;
                                result.data.count.problems = result.data.count.critical + result.data.count.unknown + result.data.count.warning;
                                res.send(result);
                            } else {
                                res.status(response.statusCode);
                                res.send({msg: response.statusMessage});
                            }
                        });
                        break;
                    case 'log':
                        var type = req.params.type;
                        var starttime = req.params.starttime;
                        var endtime = req.params.endtime;
                        if (util.isset(type) && util.isset(starttime) && util.isset(endtime)) {
                            var command = '/nagios/cgi-bin/archivejson.cgi?query=alertlist&objecttypes=' + type + '&starttime=' + starttime + '&endtime=' + endtime;
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
                        break;
                }
            } else {
                res.status(400);
                res.send({msg: 'Invalid argument.'});
            }
        }
    };
    return {
        show: function(req, res) {
            _private.getStatusForDashboard(req, res);
        }
    }
}());

module.exports = statisticModule;