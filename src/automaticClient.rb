require "socket"
require_relative 'dataItem'

class AutomaticClient
	def initialize(host,port,nro)		
		@server = TCPSocket.open(host, port)
		@file = File.new("client#{nro}.txt", "a")
		puts "You are now connected to memcached."		
		run
	end

	def run	
		@saved_keys = []		
		require_data = false
		inputMsg = "init"
		while inputMsg != "quit"
			if require_data
				inputMsg = randomData
				require_data = false
			else
				inputMsg, require_data = randomCommands
			end 		
			@file.puts("Client: #{inputMsg} \n")
			@server.write inputMsg
			inMsg = @server.recv(100)
			@file.puts("Server: #{inMsg} \n") }
		end
		server.close
	end

	def randomData
		random_index = rand(0..length)
		case random_index
			when 0	
				"data"
			when 1
				"more data"
			when 2
				dataItem				
			when 3		
				inputMsg ="append #{random_key} 5"
			when 4	
				inputMsg = "set #{random_key} should fail 15"				
			when 5
				inputMsg ="get #{saved_key}"
			when 6
				inputMsg ="get #{saved_key} #{other_saved_key} "			
			else
				"it shouldn`t be anything else"
		end
	end
	def randomCommands
		length = 2
		if @saved_keys.length > 0
			saved_key = @saved_keys.sample
			other_saved_key = @saved_keys.sample
			length = 6
		end
		random_index = rand(0..length)
		require_data = random_index > 4 ? false : true
		random_key = rand(36**8).to_s(36)
		case random_index
			when 0			
				@saved_keys.push(random_key)
				inputMsg = "set #{random_key} 0 0 15" 
			when 1
				@saved_keys.push(random_key)
				inputMsg ="set #{random_key} 0 10 12"
			when 2
				inputMsg ="prepend #{random_key} 4"				
			when 3		
				inputMsg ="append #{random_key} 5"
			when 4	
				inputMsg = "set #{random_key} should fail 15"				
			when 5
				inputMsg ="get #{saved_key}"
			when 6
				inputMsg ="get #{saved_key} #{other_saved_key} "			
			else
				"it shouldn`t be anything else"
		end
		return inputMsg, require_data
	end
end