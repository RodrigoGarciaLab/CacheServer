require 'socket'
require_relative 'cache'
require_relative 'methodParameters'
require 'json'

class Server

	def initialize(ip,port,cache_max_size,msg_max_size)
		@cache   	  = Cache.instance  	
		@server  	  = TCPServer.open(ip, port)
		@clients 	  = Hash.new
		@output 	  = Output.instance 
		@msg_max_size = msg_max_size
		@cache.setMaxSize(cache_max_size)

		@params  		   = MethodsParameters.instance
		@params_amounts    = @params.getParametersAmounts		
		@public_commands   = @params_amounts.keys	
		@strgCommandsNames = @params.getStorageCommands	
		@byte_size_pos     = @params.getByteSizePos
		run
	end

	def run
		loop do
			Thread.start(@server.accept) do |client|
				p "llega cliente"
				loop do					
					inMsg = client.recv(@msg_max_size).chomp					
					if inMsg.strip. == "quit" #mejorar
						break
					end
					#p "Parse: #{inMsg}"
					parse_input(client, inMsg)
				end
				client.puts "Closing memcached. Bye!"
				client.close
				Thread.kill
			end
		end
	end

	def is_number? string
	  true if Integer(string) rescue false
	end

	def numericArgs(args)
		args.all? {|arg| is_number? arg} 
	end

	def getData(client, byte_size)
		peek =  client.recv(@msg_max_size,Socket::MSG_PEEK) 
      	data = client.recv(byte_size)	
      	
      	if peek.bytesize > byte_size # clean buffer
	      	rest = []
			while true													
			  partial_data = client.recv(@msg_max_size)							  
			  if partial_data.length < @msg_max_size
			    break
			  end
			  rest << partial_data
			end
		end	
		data			      	
	end

	def parse_input(client, str_params)
	    commands = str_params.split
	    cmd_name  = commands.shift #[0]
	    if cmd_name.nil?	    	
	    	client.write @output.error
	    else
		    if !@public_commands.include? cmd_name #if is not a valid command return error		    	
		    	client.write @output.error
		    else # cmd_name is a valid commandy	
	      		if @strgCommandsNames.include? cmd_name  
	      			required_amount = @params_amounts[cmd_name].first
			      	if commands.length != required_amount # check if the amount of parameters is the same as expected.
			      		# SEGUIR ACAAA NO REPLY
			      		if (commands.length == required_amount + 1) and (commands[commands.length] == "noreply")
			      			noreply = true
			      		else
			      			outMsg = "#{@output.client_error} : #{cmd_name} should have exactly #{required_amount.to_s} parameters."
			      		end
			      	else
			      		key , *string_args = commands   # check if parameters after key are integers.			      		
			      		if !numericArgs(string_args) 			      			
			      			outMsg = "#{@output.client_error} : #{cmd_name} parameters must be integers (except key)."
			      			client.write outMsg
			      			return
			      		end
			      		# quiza con try catch puedo ahorrar codigo
			      		numeric_args = string_args.map(&:to_i) # now i know parameters are integers, i convert them
			      		commands = key , *numeric_args

				      	client.write "Now send the data you want to store" # then request data block				      	
				      	byte_size = numeric_args[@byte_size_pos[cmd_name]]	
				      	string_data = getData(client,100) #byte_size
				      	data = JSON.parse(string_data)	
				      	data = data[0..byte_size-1]	
				      	p data	
				      	p data.pack("C*")	      	
				      	commands.push(data)	
				    end
				end
				# p commands
				# p cmd_name
				outMsg = @cache.send(cmd_name, *commands)				
			end   
			client.write outMsg			
		end	    
	end

end