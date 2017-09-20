def log(msg, server = nil)
    if (server)        
        puts "#{server}: #{msg}"
        return
    end
    puts msg
end