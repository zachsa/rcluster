require_relative './tools/log.rb'

class Server
    @user = nil
    @host = nil
    @keys = nil
    @server = nil

    def initialize(user, host, keys)
        @user = user
        @host = host
        @keys = keys
        @server = Net::SSH.start( @host, @user, :key_data => @keys, :keys_only => TRUE)
    end

    def printOut(result)
        if (result == "")
            log "Success.", @host
        else
            log result, @host
        end
    end

    def upload(localPath, destPath, verbose = true)
        cmd = "scp #{localPath} #{@user}@#{@host}:#{destPath}"
        r = system(cmd)
        if verbose
            printOut r
        end
    end

    def appendFromString(string, destPath, verbose = true)
        cmd = "echo '#{string}' >> #{destPath};"
        r = @server.exec!(cmd);
        if verbose
            printOut r
        end
    end

    def appendFromPath(localPath, destPath, verbose = true)
        cmd = "cat #{localPath} | ssh #{@user}@#{@host} \"cat >> #{destPath}\""
        r = system(cmd)
        if verbose
            printOut r
        end
    end

    def execute(localPath, verbose = true)
        code = File.read(localPath)
        cmds =
            """
            touch tempScript.sh;
            chmod 700 tempScript.sh;
            echo '#{code}' >> tempScript.sh;
            ./tempScript.sh;
            rm tempScript.sh;
            """
        result = @server.exec!(cmds)
        if verbose
            printOut(result)
        end
    end

    def overwriteFile(localPath, destination, verbose = true)
        filecontents = File.read(localPath)
        cmds =
            """
            rm #{destination};
            touch #{destination};
            chmod 644 #{destination};
            echo '#{filecontents}' >> #{destination};
            """
        result = @server.exec!(cmds)
        if verbose
            printOut(result)
        end
    end

    def removeFile(path, verbose = true)
        cmds = 
            """
            rm #{path};
            """
        result = @server.exec!(cmds);
        if verbose
            printOut(result)
        end
    end

    def doCommand(cmd, verbose = true)
        result = @server.exec!(cmd);
        if verbose
            printOut(result)
        end
    end

    def close
        @server.close
    end
end