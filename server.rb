require 'socket'
require_relative 'cache'

class Server

  def initialize(ip,port,max_size)
  	@cache = Cache.instance
  	@cache.setMaxSize(max_size)
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:clients] = @clients
    run
  end

  def run
	loop do
	  Thread.start(@server.accept) do |client|
	    loop do
			inMsg = client.gets
			if inMsg.strip.include? "quit"
				break
			end
			#puts inMsg
			parseInput(client, inMsg)
			#client.puts "Received!"
	    end
	    client.puts "Closing memcached. Bye!"
	    client.close
	    Thread.kill
	 end
	end
  end

  def parseInput(client, strParams)
    params   = strParams.split("\r\n")    
    
    commands = params[0].split
    cmdName  = commands.shift #[0]
    if cmdName.nil?
    	client.puts ""
    else
	    if @cache.respond_to?(cmdName)
	      strgCommandsNames = StorageCommands.instance_methods(false)
	      if  strgCommandsNames.to_s.include? (cmdName)    
	      	client.puts "now data"
	      	data     =  client.gets.strip
	        commands.push(data)
	      end
	      #puts cmdName + commands.inspect
	      outMsg = @cache.send(cmdName, *commands )
	      client.puts outMsg
	    else
	      client.puts cmdName +" is not a known command"
	    end
	 end
  end
end

