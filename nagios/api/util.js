var Utility = (function() {
    var request = require('request');
    var _private = {
        checkVariable: function(variable) {
            return typeof(variable) !== 'undefined' && variable !== null && variable !== '';
        },
        sendRequest: function(command, callback) {
            var url = 'http://localhost' + command;

            request.get(url, function(error, response, body) {
                if (!error && response.statusCode == 200) {
                    console.log('url: ' + url);
                    console.log('success: true');
                    callback({success: true, body: body});
                } else {
                    console.error(response);
                    callback({success: false, statusCode: response.statusCode, 
                        statusMessage: response.statusMessage});
                }
            }).auth('nagiosadmin', 'qwe123', false);
        },
        buildConfigsContents: function(payload, type) {
            var payload = JSON.parse(payload);
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
        writeConfigFile: function(config, configs, callback) {
            // delete cfg file
            var result = _private.executeShell('rm -f ' + config);
            if (!result) {
                console.log('Failed to delete file. "' + config + '"');
                callback({success: false, statusCode: 400, 
                    statusMessage: 'Failed to delete file.'});
            }

            // save cfg file
            var fs = require('fs');
            fs.writeFile(config, configs, function(error) {
                if (error) {
                    console.error(error);
                    callback({success: false, statusCode: 400, 
                        statusMessage: 'Failed to write file.'});
                }
                console.log('Succeeded to save file. "' + config + '"');
                callback({success: true, statusCode: 200, 
                    statusMessage: 'Succeeded to save file.'});
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
        send: function(command, callback) {
            _private.sendRequest(command, callback);
        },
        make: function(payload, type) {
            return _private.buildConfigsContents(payload, type);
        },
        write: function(config, configs, callback) {
            _private.writeConfigFile(config, configs, callback);
        },
        execute: function(command) {
            return _private.executeShell(command);
        }
    }
}());

module.exports = Utility;