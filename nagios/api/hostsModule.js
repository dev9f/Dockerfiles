var hostsModule = (function() {
    var _private = {
        getHostsStatusList: function(req) {
            return { message: 'hostsModule getHostsStatusList' };
        },
        saveHostConfig: function(req) {
            return { message: 'hostsModule saveHostConfig' };
        },
        getHostStatusDetail: function(req) {
            return { message: 'hostsModule getHostStatusDetail' };
        }
    };
    return {
        index: function(req) {
            return _private.getHostsStatusList(req);
        },
        store: function(req) {
            return _private.saveHostConfig(req);
        },
        show: function(req) {
            return _private.getHostStatusDetail(req);
        }
    }
}());

module.exports = hostsModule;