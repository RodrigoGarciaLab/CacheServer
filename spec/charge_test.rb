require_relative 'src/automatic_client'

port = 6393
host = "localhost"

desired_clients = 10


my_threads = []
for i in 1..desired_clients do
    puts "Creating thread #{i}"
    my_threads << Thread.new(i) do |j|
        AutomaticClient.new(host,port,i)
    end
end

loop do
    sleep(1)
    puts 'work in main thread'
end

# while i < desired_clients  do
   
# end