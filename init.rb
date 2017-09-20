require 'json'
require_relative 'rcluster/tools/log.rb'
require 'net/http'

# Load config
file = File.read("config.json")
config = JSON.parse(file)
knownHostsDir = config["knownHostsDir"]
privateKey = config["PrivateKey"]
servers = config["Servers"]
user = config["User"]
couchUser = config["CouchUser"]
couchPswd = config["CouchPswd"]
couchBindPort = config["CouchBindPort"]
dbs = config["DBs"]

# Remove known_host keys from local server (otherwise script jams)
log "Resetting known_hosts...", 'localhost'
system("rm #{knownHostsDir}")
system("touch #{knownHostsDir}")
log "Complete.", 'localhost'

# Start server provisioning processess
servers.each { |host|
    fork {
        exec "ruby ./rcluster/index.rb #{host} #{user} #{couchPswd} #{privateKey}"
    }
}
Process.waitall()

# CouchDB nodes cluster setup already done via debconf preseed

# Add cluster nodes
coOrdinator = servers[0]
servers[1..-1].each { |host|
    log "Adding #{host} to cluster", 'localhost'
    cmd = "curl -X POST -H \"Content-Type: application/json\" http://#{couchUser}:#{couchPswd}@#{coOrdinator}:#{couchBindPort}/_cluster_setup -d '{\"action\": \"enable_cluster\", \"bind_address\":\"#{coOrdinator}\", \"username\": \"#{couchUser}\", \"password\":\"#{couchPswd}\", \"port\": #{couchBindPort}, \"node_count\": \"#{servers.length}\", \"remote_node\": \"#{host}\", \"remote_current_user\": \"#{couchUser}\", \"remote_current_password\": \"#{couchPswd}\" }'"
    system(cmd)
    cmd = "curl -X POST -H \"Content-Type: application/json\" http://#{couchUser}:#{couchPswd}@#{coOrdinator}:#{couchBindPort}/_cluster_setup -d '{\"action\": \"add_node\", \"host\":\"#{host}\", \"port\": \"#{couchBindPort}\", \"username\": \"#{couchUser}\", \"password\":\"#{couchPswd}\"}'"
    system(cmd)
    log "Complete.", 'localhost'
}

# Finalize cluster
log "Finalizing cluster", 'localhost'
cmd = "curl -X POST -H \"Content-Type: application/json\" http://#{couchUser}:#{couchPswd}@#{coOrdinator}:#{couchBindPort}/_cluster_setup -d '{\"action\": \"finish_cluster\"}'"
system(cmd)
log "Complete.", 'localhost'

# Create the MSc database
dbs.each { |db|
    name = db["name"]
    q = db["q"]
    n = db["n"]
    log "Creating database #{name}", 'localhost'
    cmd = "curl -X PUT \"http://#{couchUser}:#{couchPswd}@#{coOrdinator}:#{couchBindPort}/#{name}?n=#{n}&q=#{q}\""
    system(cmd)
    log "Complete.", 'localhost'
}

# Script finished!
log("All servers setup complete!")
exit 0