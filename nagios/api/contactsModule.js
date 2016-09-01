var util = require('./util.js');

var contactsModule = (function() {
    var _private = {
        writeContactConfig: function(req, res) {
            var payload = req.body.payload;
            if (util.isset(payload)) {
                var configs = util.make(payload, 'contact');
                var config = '/app/nagios/etc/servers/contacts.cfg';
                util.write(config, configs, function(response) {
                    res.status(response.statusCode);
                    res.send({msg: response.statusMessage});
                });
            } else {
                res.status(400);
                res.send({msg: 'Invalid argument.'});
            }
        }
    };
    return {
        store: function(req, res) {
            _private.writeContactConfig(req, res);
        }
    }
}());

module.exports = contactsModule;
