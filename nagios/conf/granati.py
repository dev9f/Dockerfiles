#!/usr/bin/python
# vim: set ts=4 sts=4 sw=4 tw=79 et :
# Provenance: https://github.com/shawn-sterling/graphios/graphios.py

from ConfigParser import SafeConfigParser
from optparse import OptionParser
import logging
import logging.handlers
import os
import os.path
import sys

# ##########################################################
# ###  Do not edit this file, edit the granati.cfg    #####

# nagios spool directory
spool_directory = '/var/spool/nagios/granati'

# granati log info
log_file = ''
log_max_size = 24
log = logging.getLogger('log')

# by default we will check the current path for granati.cfg
# if config_file is passed as a command line argument
# we will use that instead.
config_file = ''

# This is overridden via config file
debug = False

# config dictionary
cfg = {}

# backend global
be = ""

# available loglevels for granati.cfg
loglevels = {
    'logging.DEBUG':    logging.DEBUG,
    'logging.INFO':     logging.INFO,
    'logging.WARNING':  logging.WARNING,
    'logging.ERROR':    logging.ERROR,
    'logging.CRITICAL': logging.CRITICAL
}

# options parsing
parser = OptionParser("""usage: %prog [options]
sends nagios performance data to influxdb.
""")

parser.add_option('-v', "--verbose", action="store_true", dest="verbose",
                  help="sets logging to DEBUG level")
parser.add_option('-q', "--quiet", action="store_true", dest="quiet",
                  help="sets logging to WARNING level")
parser.add_option("--spool-directory", dest="spool_directory",
                  default=spool_directory,
                  help="where to look for nagios performance data")
parser.add_option("--log-file", dest="log_file",
                  default=log_file,
                  help="file to log to")
parser.add_option("--backend", dest="backend", default="stdout",
                  help="sets which storage backend to use")
parser.add_option("--config_file", dest="config_file", default="",
                  help="set custom config file location")
parser.add_option("--test", action="store_true", dest="test", default="",
                  help="Turns on test mode, which won't send to backends")
parser.add_option("--replace_char", dest="replace_char", default="_",
                  help="Replacement Character (default '_'")
parser.add_option("--sleep_time", dest="sleep_time", default=15,
                  help="How much time to sleep between checks")
parser.add_option("--sleep_max", dest="sleep_max", default=480,
                  help="Max time to sleep between runs")
parser.add_option("--server", dest="server", default="",
                  help="Server address (for backend)")
parser.add_option("--no_replace_hostname", action="store_false",
                  dest="replace_hostname", default=True,
                  help="Replace '.' in nagios hostnames, default on.")
parser.add_option("--reverse_hostname", action="store_true",
                  dest="reverse_hostname",
                  help="Reverse nagios hostname, default off.")


def print_debug(msg):
    """
    prints a debug message if global debug is True
    """
    if debug:
        print msg

def read_config(config_file):
    """
    reads the config file
    """
    if config_file == '':
        # check same dir as granati binary
        my_file = "%s/granati.cfg" % sys.path[0]
        if os.path.isfile(my_file):
            config_file = my_file
    config = SafeConfigParser()
    # The logger won't be initialized yet, so we use print_debug
    if os.path.isfile(config_file):
        config.read(config_file)
        config_dict = {}
        for section in config.sections():
            # there should only be 1 'granati' section
            print_debug("section: %s" % section)
            config_dict['name'] = section
            for name, value in config.items(section):
                config_dict[name] = chk_bool(value)
                print_debug("config[%s]=%s" % (name, value))
        # print config_dict
        return config_dict
    else:
        print_debug("Can't open config file: %s" % config_file)
        print """\nEither modify the script at the config_file = '' line and
specify where you want your config file to be, or create a config file
in the above directory (which should be the same dir the granati.py is in)
or you can specify --config=myconfigfilelocation at the command line."""
        sys.exit(1)


def verify_config(config_dict):
    """
    verifies the required config variables are found
    """
    global spool_directory
    ensure_list = ['replacement_character', 'log_file', 'log_max_size',
                   'log_level', 'sleep_time', 'sleep_max', 'test_mode',
                   'reverse_hostname', 'replace_hostname']
    missing_values = []
    for ensure in ensure_list:
        if ensure not in config_dict:
            missing_values.append(ensure)
    if len(missing_values) > 0:
        print "\nMust have value in config file for:\n"
        for value in missing_values:
            print "%s\n" % value
        sys.exit(1)
    if not config_dict['log_level'] in loglevels.keys():
        print "Unknown loglevel: " + config_dict['log_level'] + '\n'
        print "Available loglevels:"
        print '\n'.join(sorted(loglevels.keys()))
        sys.exit(1)
    if "spool_directory" in config_dict:
        spool_directory = config_dict['spool_directory']

def verify_options(opts):
    """
    verify the passed command line options, puts into global cfg
    """
    global cfg
    global spool_directory
    # because these have defaults in the parser section we know they will be
    # set. So we don't have to do a bunch of ifs.
    if "log_file" not in cfg:
        cfg["log_file"] = opts.log_file
    if cfg["log_file"] == "''" or cfg["log_file"] == "":
        cfg["log_file"] = "%s/granati.log" % sys.path[0]
    cfg["log_max_size"] = 24
    if opts.verbose:
        cfg["debug"] = True
        cfg["log_level"] = "logging.DEBUG"
    elif opts.quiet:
        cfg["debug"] = False
        cfg["log_level"] = "logging.WARNING"
    else:
        cfg["debug"] = False
        cfg["log_level"] = "logging.INFO"
    if opts.test:
        cfg["test_mode"] = True
    else:
        cfg["test_mode"] = False
    cfg["replacement_character"] = opts.replace_char
    cfg["spool_directory"] = opts.spool_directory
    cfg["sleep_time"] = opts.sleep_time
    cfg["sleep_max"] = opts.sleep_max
    cfg["replace_hostname"] = opts.replace_hostname
    cfg["reverse_hostname"] = opts.reverse_hostname
    spool_directory = opts.spool_directory
    handle_backends(opts)
    return cfg

def handle_backends(opts):
    global cfg
    if opts.backend == "influxdb":
        cfg["enable_influxdb"] = True
    else:
        print opts.backend + " is preparing."
        sys.exit(1)

def configure():
    """
    sets up graphios config
    """
    global debug
    try:
        cfg["log_max_size"] = int(cfg["log_max_size"])
    except ValueError:
        print "log_max_size needs to be a integer"
        sys.exit(1)

    # Convert cfg["log_max_size"] to bytes. Assume its already in bytes
    # if its > 1000000
    if cfg["log_max_size"] < 1000000:
        log_max_bytes = cfg["log_max_size"]*1024*1024
    else:
        log_max_bytes = cfg["log_max_size"]

    log_handler = logging.handlers.RotatingFileHandler(
        cfg["log_file"], maxBytes=log_max_bytes, backupCount=4,
        # encoding='bz2')
    )
    formatter = logging.Formatter(
        "%(asctime)s %(filename)s %(levelname)s %(message)s",
        "%B %d %H:%M:%S")
    log_handler.setFormatter(formatter)
    log.addHandler(log_handler)

    if cfg.get("debug") is True or cfg['log_level'] == 'logging.DEBUG':
        log.debug("adding streamhandler")
        log.setLevel(logging.DEBUG)
        log.addHandler(logging.StreamHandler())
        debug = True
    else:
        log.setLevel(loglevels[cfg['log_level']])
        debug = False

def main():
    print("Hello World")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        (options, args) = parser.parse_args()
        if options.config_file:
            cfg = read_config(options.config_file)
        else:
            cfg = verify_options(options)
    else:
        cfg = read_config(config_file)
    verify_config(cfg)
    configure()
    main()
