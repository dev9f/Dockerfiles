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
        writeConfigFile: function(config, configs, res) {
            // delete services.cfg file
            _private.deleteFile(config);

            // save services.cfg file
            var fs = require('fs');
            fs.writeFile(config, configs, function(error) {
                if (error) {
                    console.error(error);
                    res.status(400);
                    res.send('File writing fail.');
                }
                console.log('The ' + config + ' file was saved!');
                res.status(200);
                res.send('File writing success.');
            })
        },
        deleteFile: function(file) {
            var url = 'http://localhost/delete.php?file=' + file;

            request.get(url, function(error) {
                if (error) console.error(error);
            })
        }
    };
    return {
        isset: function(variable) {
            return _private.checkVariable(variable);
        },
        send: function(command, res) {
            _private.sendRequest(command, res);
        },
        write: function(config, configs, res) {
            _private.writeConfigFile(config, configs, res);
        }
    }
}());

module.exports = Utility;