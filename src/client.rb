require "socket"
require_relative 'data_item'

class Client
	def initialize(host,port)		
		@server = TCPSocket.open(host, port)
		puts @server.recv(100)		#greeting message
		run
	end

	def run				
		loop do
			input_msg = gets.chomp 
			if input_msg == "quit"
				break
			end
			@server.write input_msg
			in_msg = @server.recv(100)
			p in_msg
		end
		@server.close	
	end
end