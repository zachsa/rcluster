require 'net/ssh' # Documentations: http://www.rubydoc.info/github/net-ssh/net-ssh/Net/SSH
require_relative './server.rb'

# Get command arguments for process
HOST = ARGV[0]
USER = ARGV[1]
COUCH_PSWD = ARGV[2]
P_KEY_PATH = ARGV[3]

# Configuration
KEYS = [File.read(P_KEY_PATH)]
USER = "root" 



# Login to server via SSH
log "Logging into #{HOST}...", HOST
server = Server.new(USER, HOST, KEYS)

# Set HOST name
log "Changing hostname...", HOST
server.doCommand "hostname #{HOST}; rm /etc/hostname; touch /etc/hostname; echo #{HOST} >> /etc/hostname; chmod 466 /etc/hostname;", false
log "Complete.", HOST

# Install general tools
log "Installing basic tooling...", HOST
server.execute "./lib/tools/install.sh", false
log "Complete.", HOST

# # Install and Configure Nginx
# log "Installing Nginx...", HOST
# server.execute "./lib/nginx/install.sh", false
# server.removeFile "/etc/nginx/sites-available/default", false
# server.removeFile "/etc/nginx/sites-enabled/default", false
# server.upload "./lib/nginx/nginx.conf", "/etc/nginx/nginx.conf", false
# server.doCommand "service nginx reload;", false
# log "Complete.", HOST

# Install CouchDB
log "Installing CouchDB...", HOST
server.doCommand "echo 'deb https://apache.bintray.com/couchdb-deb xenial main' | sudo tee -a /etc/apt/sources.list", false
server.doCommand "curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc | sudo apt-key add -", false
server.doCommand "apt-get update", false
server.doCommand "debconf-set-selections <<< 'couchdb couchdb/bindaddress string 0.0.0.0';", false
server.doCommand "debconf-set-selections <<< 'couchdb couchdb/cookie string monster';", false
server.doCommand "debconf-set-selections <<< 'couchdb couchdb/mode string clustered';", false
server.doCommand "debconf-set-selections <<< 'couchdb couchdb/nodename string couchdb@#{HOST}';", false
server.doCommand "debconf-set-selections <<< 'couchdb couchdb/adminpass password #{COUCH_PSWD}';", false
server.doCommand "debconf-set-selections <<< 'couchdb couchdb/adminpass_again password #{COUCH_PSWD}';", false
server.doCommand "apt-get install couchdb -y", false
log "Complete.", HOST

# # configure CouchDB
# log "Configuring CouchDB...", HOST
# server.doCommand "adduser --system --shell /bin/bash --group --gecos \"CouchDB Administrator\" couchdb;", false
# server.doCommand "chown -R couchdb:couchdb /opt/couchdb;", false
# server.doCommand "find /opt/couchdb -type d -exec chmod 0770 {} \;", false
# server.doCommand "chmod 0644 /opt/couchdb/etc/*;", false
# log "Complete.", HOST

# # Start CouchDB server daemon
# log "Starting CouchDB deamons...", HOST
# server.execute "./lib/couchdb/daemons/setup.sh", false 
# server.upload "./lib/couchdb/daemons/run-logs.sh", "/etc/sv/couchdb/log/run", false
# server.upload "./lib/couchdb/daemons/run-couch.sh", "/etc/sv/couchdb/run", false
# server.doCommand "chmod u+x /etc/sv/couchdb/log/run;", false
# server.doCommand "chmod u+x /etc/sv/couchdb/run;", false
# server.doCommand "ln -s /etc/sv/couchdb/ /etc/service/couchdb;", false
# log "Complete.", HOST

# Close connection
log "Closing connection...", HOST
server.close
log "Complete.", HOST

log "Server setup complete!", HOST
Process.exit