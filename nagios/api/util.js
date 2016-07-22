var Utility = (function() {
    var request = require('request');
    var _private = {
        checkVariable: function(variable) {
            return typeof(variable) !== 'undefined' && variable !== null && variable !== '';
        },
        sendRequest: function(command, res) {
            var url = 'http://localhost' + command;

            request.get(url, function(error, response, body) {
                if (error) {
                    console.error(error);
                    res.json(error);
                }
                res.json(body);
            }).auth('nagiosadmin', 'qwe123', false);
        },
        buildConfigsContents: function(payload, type) {
            var configs = '';

            for (x in payload) {
                var details = payload[x]['details'];
                var config = '';

                for (y in details) {
                    config += '\t' + y + '\t' + details[y] + '\n';
                }

                configs += 'define ' + type + '{\n' + config + '}\n\n';
            }

            return configs;
        },
        writeConfigFile: function(config, configs, res) {
            // delete cfg file
            var result = _private.executeShell('rm -f ' + config);
            if (!result) {
                res.status(400);
                res.send('File removing fail.');
            }

            // save cfg file
            var fs = require('fs');
            fs.writeFile(config, configs, function(error) {
                if (error) {
                    console.error(error);
                    res.status(400);
                    res.send('File writing fail.');
                }
                console.log('The "' + config + '" file was saved!');
                res.status(200);
                res.send('File writing success.');
            })
        },
        executeShell: function(command) {
            var shell = require('shelljs');

            if (shell.exec(command).code !== 0) {
                console.error('Error. "' + command +'" does not executed.');
                return false;
            }

            return true;
        }
    };
    return {
        isset: function(variable) {
            return _private.checkVariable(variable);
        },
        send: function(command, res) {
            _private.sendRequest(command, res);
        },
        make: function(payload, type) {
            return _private.buildConfigsContents(payload, type);
        },
        write: function(config, configs, res) {
            _private.writeConfigFile(config, configs, res);
        },
        execute: function(command) {
            return _private.executeShell(command);
        }
    }
}());

module.exports = Utility;