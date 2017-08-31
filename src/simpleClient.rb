require "socket"

server = TCPSocket.open("localhost", 2626)

puts "You are now connected to memcached."
inputMsg = "init"
while inputMsg != "quit"
	inputMsg = gets.chomp 
	server.puts inputMsg
	inMsg = server.gets
	puts inMsg
end
server.close