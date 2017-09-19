require_relative '../src/automatic_client'

port = 6393
host = "localhost"

desired_clients = 10
desired_time    = 10

my_threads = []
for i in 1..desired_clients do
  puts "Creating thread #{i}"
  my_threads << Thread.new(i) do |j|
    AutomaticClient.new(host,port,i)
  end
end

p "Will work for #{desired_time} seconds."
sleep(desired_time)
puts 'Finished, check the output folder to see the log files.'
