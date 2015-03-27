require 'socket'

class Bunka
  class << self
    def create_socket
      puts 'creating socket'
      server = TCPServer.open('localhost', 2000)  # Socket to listen on port 2000
      puts 'start loop'
      loop {                         # Servers run forever
      Thread.start(server.accept) do |client|
        puts 'test geslaagd'
        client.close
      end
      puts 'voorbij server'
      }
    end
  end
end
