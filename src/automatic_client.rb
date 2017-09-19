require "socket"

class AutomaticClient # this class is just created for testing, to simulate a client
	def initialize(host,port,client_num)		
		@server       = TCPSocket.open(host, port)		
    @require_data = false	 
    @client_num = client_num
    @saved_keys   = []	
		run
	end

	def run			
		input_msg = String.new

		while input_msg != "quit"
			if @require_data # if the last command was a storage one, it sends data
				input_msg     = random_data
				@require_data = false
			else
				input_msg = random_commands
			end 		
			
			@server.write input_msg
			in_msg = @server.recv(100)

		end
		server.close
	end

	def random_data
		random_index = rand(0..3)
		case random_index
			when 0	
				"data"
			when 1
				"32445532"
			when 2
				"this data includes \n\r"				
			when 3		
				"[1,2,3,4]"	
      when 4
        [DataItem.new(1,2,3)]
			else
				"it shouldn`t be anything else"
		end
	end

	def random_commands
		length = 2
		if @saved_keys.length > 0 # if there's already a key we can select every possible command
			saved_key = @saved_keys.sample
			other_saved_key = @saved_keys.sample
			length = 6
		end
		random_index = rand(0..length)
		@require_data = random_index > 4 ? false : true
		random_key = rand(36**8).to_s(36)
		case random_index
			when 0			
				@saved_keys.push(random_key)
				input_msg = "set #{random_key} 0 0 20" 
			when 1
				@saved_keys.push(random_key)
				input_msg ="set #{random_key} 0 10 30"
			when 2
				input_msg ="prepend #{random_key} 4"				
			when 3		
				input_msg ="append #{random_key} 5"
			when 4	
				input_msg = "set #{random_key} should fail 15"				
			when 5
				input_msg ="get #{saved_key}"
			when 6
				input_msg ="get #{saved_key} #{other_saved_key} "			
			else
				"it shouldn`t be anything else"
		end
		return input_msg
	end
end