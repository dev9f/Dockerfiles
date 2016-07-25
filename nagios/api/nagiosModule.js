var util = require('./util.js');

var nagiosModule = (function() {
    var _private = {
        nagiosControl: function(req, res) {
            var paramCommand = req.params.command;
            if (util.isset(paramCommand)) {
                var command = 'sudo service nagios ' + paramCommand + ' 2>&1';
                var message;

                switch (paramCommand) {
                    case 'restart':
                        message = 'Restart success.';
                        break;
                    case 'status':
                        message = 'Nagios is running.';
                        break;
                    default:
                        res.status(400);
                        res.send({msg: 'Invalid argument.'});
                }

                var result = util.execute(command);
                if (!result) {
                    res.status(400);
                    res.send({msg: 'Can not execute the command.'});
                }

                res.status(200);
                res.send({msg: message});
            } else {
                res.status(400);
                res.send({msg: 'Invalid argument.'});
            }
        }
    };
    return {
        index: function(req, res) {
            _private.nagiosControl(req, res);
        }
    }
}());

module.exports = nagiosModule;