var Utility = (function() {
    var _private = {
        checkVariable: function(variable) {
            return typeof(variable) !== 'undefined' && variable !== null && variable !== '';
        },
        sendRequest: function(command, res) {
            var request = require('request');
            var url = 'http://localhost' + command;

            // function callback(error, response, body) {
            //     if (error) {
            //         console.error(error);
            //         return error;
            //     }
            //     console.log('Nagios API Server Response: ', body);
            //     return body;
            // }

            // request.get(url, callback).auth('nagiosadmin', 'qwe123', false);
            // request.get(url).auth('nagiosadmin', 'qwe123', false)
            //     .on('response', function(response) {
            //         if (response.statusCode == 200) {
            //             response.on('data', function(data) {
            //                 console.log('received ' + data);
            //                 return data;
            //             })
            //         }
            //     })
            //     .on('error', function(error) {
            //         console.log(error);
            //         return error;
            //     });

            request.get(url, function(error, response, body) {
                if (error) {
                    console.error(error);
                    res.send(error);
                }
                res.send(body);
            }).auth('nagiosadmin', 'qwe123', false);
        }
    };
    return {
        isset: function(variable) {
            return _private.checkVariable(variable);
        },
        send: function(command, res) {
            _private.sendRequest(command, res);
            // return _private.sendRequest(command);
        }
    }
}());

module.exports = Utility;