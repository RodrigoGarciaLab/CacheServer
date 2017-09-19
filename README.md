# RGCacheServer

RGCacheServer is a ruby cache server based on the especifications of Memcached (http://memcached.org/). It´s a shortened version of the original one, as it only implements it´s fundamental functions.

### How it works

- To get started you should first run the main_server.rb file and then main_client.rb. From then you will start interacting     whith the server as the client, via the supported commands that will be described below. 


### Supported commands

##### Storage commands
        
        set: stores the data no matter what
        add: stores the data, only if the server doesn't already hold data for the indicated key
        replace: stores the data, only if the server does already hold data for the indicated key
        append: add the data to an existing key after existing data
        prepend: add the data to an existing key before existing data
        cas: stores the data but only if no one else has updated since the user last fetched it
- the expected format is the following:<br>
\<command name\> \<key\> \<flags\> \<exptime\> \<bytes\> [noreply]\r\n
- After this line, the client sends the data block:<br>
\<data block\>\r\n
        
##### Retrieval commands


        get: retrieves the key, flags, size and data for every sent key
        gets: retrieves the key, flags, size, cas unique id and data for every sent key
        
- the expected format is the following:<br>
\<command name\> \<key\>*\r\n

### Testing

- Inside the spec folder there are some files that test cache's primal functionalities.
- There is also a file named "charge_test.rb" that, when executed, will create 10 clients and will make them interact with the Cache Server for 10 seconds
