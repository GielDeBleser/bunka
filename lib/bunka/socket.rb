require 'socket'

class Bunka
  class << self
    def create_socket
      server = TCPServer.open('localhost', 2000)  # Socket to listen on port 2000
      loop {                         # Servers run forever
      Thread.start(server.accept) do |client|
        puts 'test geslaagd' 
        client.close
      end
      }
    end
  end
end
