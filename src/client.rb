require "socket"
require 'byebug'

server = TCPSocket.open("localhost", 2626)

puts "You are now connected to memcached."
inputMsg = "init"

while inputMsg != "quit"
	#byebug
	puts "1"
	inputMsg = gets.chomp 
	puts "2"
	server.puts inputMsg
	puts "3"
	inMsg = server.gets
	puts "4"
	puts inMsg
end
server.close