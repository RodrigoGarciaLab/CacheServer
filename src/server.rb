require 'socket'
require_relative 'cache'
require_relative 'methodParameters'
require 'byebug'

class Server

	def initialize(ip,port,cache_max_size,msg_max_size)
		@cache   = Cache.instance  	
		@server  = TCPServer.open(ip, port)
		@clients = Hash.new
		@output  = Output.instance 
		@msg_max_size = msg_max_size
		@cache.setMaxSize(cache_max_size)

		@params  = MethodsParameters.instance
		@params_amounts =  @params.getParametersAmounts		
		@public_commands = @params_amounts.keys	
		@strgCommandsNames = @params.getStorageCommands	
		run
	end

	def run
		loop do
			Thread.start(@server.accept) do |client|
				loop do
					inMsg = client.recv(@msg_max_size).chomp					
					if inMsg.strip. == "quit" #mejorar
						break
					end
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

	def parse_input(client, str_params)
	    commands = str_params.split
	    cmd_name  = commands.shift #[0]
	    if cmd_name.nil?
	    	client.write @output.error
	    else
		    if !@public_commands.include? cmd_name #if is not a valid command return error
		    	client.write @output.error
		    else	
	      		if @strgCommandsNames.include? cmd_name  
	      			required_amount = @params_amounts[cmd_name].first
			      	if commands.length != required_amount # check if the amount of parameters is the same as expected.
			      		outMsg = "#{@output.client_error} : #{cmd_name} should have exactly #{required_amount.to_s} parameters."
			      	else
			      		key , *numeric_args = commands   # check if parameters after key are integers.			      		
			      		if !numericArgs(numeric_args)
			      			outMsg = "#{@output.client_error} : #{cmd_name} parameters must be integers."
			      			client.write outMsg
			      			return
			      		end
				      	client.write "Send Data" # then request data block
				      	byte_size = numeric_args[1]
				      	data =  client.recv(100)
				      	commands.push(data)
				      	#p commands
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