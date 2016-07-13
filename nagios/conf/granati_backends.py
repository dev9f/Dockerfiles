# vim: set ts=4 sts=4 sw=4 tw=79 et :
# Provenance: https://github.com/shawn-sterling/graphios/graphios_backends.py

import logging
import sys
import urllib2
import json

# ###########################################################
# #### influxdb backend  ####################################

class influxdb(object):
    def __init__(self, cfg):
        self.log = logging.getLogger("log.backends.influxdb")
        self.log.info("InfluxDB backend initialized")
        self.scheme = "http"
        self.default_ports = {'https': 8087, 'http': 8086}
        self.timeout = 5

        if 'influxdb_use_ssl' in cfg:
            if cfg['influxdb_use_ssl']:
                self.scheme = "https"

        if 'influxdb_servers' in cfg:
            self.influxdb_servers = cfg['influxdb_servers'].split(',')
        else:
            self.influxdb_servers = ['127.0.0.1:%i' %
                                     self.default_ports[self.scheme]]

        if 'influxdb_user' in cfg:
            self.influxdb_user = cfg['influxdb_user']
        else:
            self.log.critical("Missing influxdb_user in graphios.cfg")
            sys.exit(1)

        if 'influxdb_password' in cfg:
            self.influxdb_password = cfg['influxdb_password']
        else:
            self.log.critical("Missing influxdb_password in graphios.cfg")
            sys.exit(1)

        if 'influxdb_db' in cfg:
            self.influxdb_db = cfg['influxdb_db']
        else:
            self.influxdb_db = "nagios"

        if 'influxdb_max_metrics' in cfg:
            self.influxdb_max_metrics = cfg['influxdb_max_metrics']
        else:
            self.influxdb_max_metrics = 250

        try:
            self.influxdb_max_metrics = int(self.influxdb_max_metrics)
        except ValueError:
            self.log.critical("influxdb_max_metrics needs to be a integer")
            sys.exit(1)

    def build_url(self, server):
        """ Returns a url to specified InfluxDB-server """
        test_port = server.split(':')
        if len(test_port) < 2:
            server = "%s:%i" % (server, self.default_ports[self.scheme])

        return "%s://%s/db/%s/series?u=%s&p=%s" % (self.scheme, server,
                                                   self.influxdb_db,
                                                   self.influxdb_user,
                                                   self.influxdb_password)

    def build_path(self, m):
        """ Returns a path """
        path = ""
        if m.METRICBASEPATH != "":
            path += "%s." % m.METRICBASEPATH

        if m.GRAPHITEPREFIX != "":
            path += "%s." % m.GRAPHITEPREFIX

        path += "%s." % m.HOSTNAME

        if m.SERVICEDESC != "":
            path += "%s." % m.SERVICEDESC

        path = "%s%s" % (path, m.LABEL)

        if m.GRAPHITEPOSTFIX != "":
            path = "%s.%s" % (path, m.GRAPHITEPOSTFIX)

        return path

    def chunks(self, l, n):
        """ Yield successive n-sized chunks from l. """
        for i in xrange(0, len(l), n):
            yield l[i:i+n]

    def url_request(self, url, chunk):
        json_body = json.dumps(chunk)
        req = urllib2.Request(url, json_body)
        req.add_header('Content-Type', 'application/json')
        return req

    def _send(self, server, chunk):
        self.log.debug("Connecting to InfluxDB at %s" % server)
        req = self.url_request(self.build_url(server), chunk)

        try:
            r = urllib2.urlopen(req, timeout=self.timeout)
            r.close()
            return True
        except urllib2.HTTPError as e:
            body = e.read()
            self.log.warning('Failed to send metrics to InfluxDB. \
                                Status code: %d: %s' % (e.code, body))
            return False
        except IOError as e:
            fail_string = "Failed to send metrics to InfluxDB. "
            if hasattr(e, 'code'):
                fail_string = fail_string + "Status code: %s" % e.code
            if hasattr(e, 'reason'):
                fail_string = fail_string + str(e.reason)
            self.log.warning(fail_string)
            return False

    def send(self, metrics):
        """ Connect to influxdb and send metrics """
        ret = 0
        perfdata = {}
        series = []
        for m in metrics:
            ret += 1

            path = self.build_path(m)

            if path not in perfdata:
                perfdata[path] = []

            # influx assumes timestamp in milliseconds
            timet_ms = int(m.TIMET)*1000

            # Ensure a int/float gets passed
            try:
                value = int(m.VALUE)
            except ValueError:
                try:
                    value = float(m.VALUE)
                except ValueError:
                    value = 0

            perfdata[path].append([timet_ms, value])

        for k, v in perfdata.iteritems():
            series.append({"name": k, "columns": ["time", "value"],
                           "points": v})

        series_chunks = self.chunks(series, self.influxdb_max_metrics)
        for chunk in series_chunks:
            for s in self.influxdb_servers:
                if not self._send(s, chunk):
                    ret = 0

        return ret


# ###########################################################
# #### influxdb-0.9 backend  ####################################

class influxdb09(influxdb):
    def __init__(self, cfg):
        influxdb.__init__(self, cfg)
        if 'influxdb_extra_tags' in cfg:
            self.influxdb_extra_tags = ast.literal_eval(
                cfg['influxdb_extra_tags'])
            print self.influxdb_extra_tags
        else:
            self.influxdb_extra_tags = {}

        try:
            cfg['influxdb_line_protocol']
            self.influxdb_line_protocol = cfg['influxdb_line_protocol']
        except:
            self.influxdb_line_protocol = False

    def build_url(self, server):
        """ Returns a url to specified InfluxDB-server """
        test_port = server.split(':')
        if len(test_port) < 2:
            server = "%s:%i" % (server, self.default_ports[self.scheme])

        if self.influxdb_line_protocol:
            return "%s://%s/write?u=%s&p=%s&db=%s" % (self.scheme, server,
                                                      self.influxdb_user,
                                                      self.influxdb_password,
                                                      self.influxdb_db)
        else:
            return "%s://%s/write?u=%s&p=%s" % (self.scheme, server,
                                                self.influxdb_user,
                                                self.influxdb_password)

    def url_request(self, url, chunk):
        if self.influxdb_line_protocol:
            req = urllib2.Request(url, chunk)
            req.add_header('Content-Type', 'application/x-www-form-urlencoded')
            return req
        else:
            return super(influxdb09, self).url_request(url, chunk)

    def format_metric(self, timestamp, path, tags, value):
        if not self.influxdb_line_protocol:
            return {
                    "timestamp": timestamp,
                    "measurement": path,
                    "tags": tags,
                    "fields": {"value": value}}
        return '%s,%s value=%s %d' % (
                path,
                ','.join(['%s=%s' % (k, v) for k, v in tags.iteritems() if v]),
                value,
                timestamp * 10 ** 9
                )

    def format_series(self, chunk):
        if self.influxdb_line_protocol:
            return '\n'.join(chunk)
        else:
            return {"database": self.influxdb_db, "points": chunk}

    def send(self, metrics):
        """ Connect to influxdb and send metrics """
        ret = 0
        perfdata = []
        for m in metrics:
            ret += 1

            if (m.SERVICEDESC == ''):
                path = m.HOSTCHECKCOMMAND
            else:
                path = m.SERVICEDESC

            # Ensure a int/float gets passed
            try:
                value = int(m.VALUE)
            except ValueError:
                try:
                    value = float(m.VALUE)
                except ValueError:
                    value = 0

            tags = {"check": m.LABEL, "host": m.HOSTNAME}
            tags.update(self.influxdb_extra_tags)

            perfdata.append(self.format_metric(int(m.TIMET), path,
                            tags, value))

        series_chunks = self.chunks(perfdata, self.influxdb_max_metrics)
        for chunk in series_chunks:
            series = self.format_series(chunk)
            for s in self.influxdb_servers:
                if not self._send(s, series):
                    ret = 0

        return ret


# ###########################################################
# #### start here  #######################################

if __name__ == "__main__":
    print("I'm just a lowly module. Try calling granati.py instead")
    sys.exit(42)
