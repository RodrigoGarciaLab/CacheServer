require "socket"
require_relative 'dataItem'

class Client
	def initialize(host,port)		
		@server = TCPSocket.open(host, port)
		puts "You are now connected to memcached."		
		run
	end

	def run
		p "running"
		inputMsg = "init"
		while @inputMsg != "quit"
			inputMsg = gets.chomp 
			if inputMsg.include? "data"				
				inputMsg = [DataItem.new(1,2,3)]
				mymsg = "dale\n".unpack("C*")
				p mymsg
				inputMsg = mymsg
			end
			@server.write inputMsg
			inMsg = @server.recv(100)
			p inMsg
		end
		server.close	
	end
end