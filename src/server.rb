require 'socket'
require_relative 'cache'
require 'byebug'

class Server

  def initialize(ip,port,max_size)
  	@cache   = Cache.instance  	
    @server  = TCPServer.open( ip, port )
    @clients = Hash.new
    @output  = Output.instance 
    @cache.setMaxSize(max_size)
    run
  end

  def run
	loop do
	  Thread.start(@server.accept) do |client|
	    loop do
	    	puts "1"
			inMsg = client.gets
			puts inMsg
			puts "2"
			if inMsg.strip.include? "quit" #mejorar
				break
			end
			puts "3"
			parse_input(client, inMsg)
			puts "4"
	    end
	    client.puts "Closing memcached. Bye!"
	    client.close
	    Thread.kill
	 end
	end
  end

  def parse_input(client, strParams)
    params   = strParams.split("\r\n")   
    commands = params[0].split
    cmdName  = commands.shift #[0]
    if cmdName.nil?
    	client.puts ""
    else
    	puts "c"
	    if @cache.respond_to?(cmdName)
	    	puts "d"
	      strgCommandsNames = ["set","add","replace","append","prepend"] 
	      if  strgCommandsNames.to_s.include? (cmdName)    
	      	puts "e"
	      	client.puts "now data"
	      	data     =  client.gets.strip
	      	puts "f"
	        commands.push(data)
	      end
	      puts "g"
	      outMsg = @cache.send(cmdName, *commands )
	      puts "h"
	      client.puts outMsg
	    else
	      client.puts @output.error
	    end
	 end
  end
end

