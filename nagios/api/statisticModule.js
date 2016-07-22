var util = require('./util.js');

var statisticModule = (function() {
    var _private = {
        getStatusForDashboard: function(req, res) {
            var id = req.params.id;
            if (util.isset(id)) {
                //
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