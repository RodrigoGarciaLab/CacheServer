require "socket"
require 'byebug'

server = TCPSocket.open("localhost", 6393)

puts "You are now connected to memcached."
inputMsg = "init"

while inputMsg != "quit"
	inputMsg = gets.chomp 
	server.write inputMsg
	inMsg = server.recv(100)
	p inMsg
end
server.close