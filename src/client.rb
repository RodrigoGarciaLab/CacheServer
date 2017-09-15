require "socket"
require_relative 'data_item'

class Client
	def initialize(host,port)		
		@server = TCPSocket.open(host, port)
		puts "You are now connected to memcached."		
		run
	end

	def run				
		loop do
			input_msg = gets.chomp 
			if input_msg == "quit"
				break
			end
			if input_msg.include? "data"				
				input_msg = [DataItem.new(1,2,3)]
				my_msg = "dale\n".unpack("C*")
				p my_msg
				input_msg = my_msg
			end
			@server.write input_msg
			in_msg = @server.recv(100)
			p in_msg
		end
		@server.close	
	end
end