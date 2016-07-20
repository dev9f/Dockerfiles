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
                    res.send(error);
                }
                res.send(body);
            }).auth('nagiosadmin', 'qwe123', false);
        },
        deleteFile: function(file) {
            var uri = 'http://localhost/delete.php?file=' + file;
            
            request.get(uri, function(error) {
                if (error) {
                    console.error(error);
                }
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
        delete: function(file) {
            return _private.deleteFile(file);
        }
    }
}());

module.exports = Utility;