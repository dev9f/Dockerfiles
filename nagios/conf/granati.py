#!/usr/bin/python
# vim: set ts=4 sts=4 sw=4 tw=79 et :
# Provenance: https://github.com/shawn-sterling/graphios/graphios.py

from optparse import OptionParser

# options parsing
parser = OptionParser("""usage: %prog [options]
sends nagios performance data to carbon.
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

def main():
    print("Hello World")

if __name__ == "__main__":
    main()
