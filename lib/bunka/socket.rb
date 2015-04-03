require 'socket'
require 'pry'

class Bunka
  class << self
    def create_failed_socket
      server1 = TCPServer.open('localhost', 2000)  
      loop{
      Thread.start(server1.accept) do |client|
        @failedarray.push client.read
        client.close
      end
      }
     end
    def create_success_socket
      server2 = TCPServer.open('localhost', 2001)
      loop{  
      Thread.start(server2.accept) do |client|
        @successarray.push client.read
        client.close
      end
      }
    end
    def create_timeout_socket
      server3 = TCPServer.open('localhost', 2002)  # Socket to listen on port 2000
      loop {                         # Servers run forever
      Thread.start(server3.accept) do |client|
        @timeoutarray.push client.read
        client.close
      end
      }
    end
      def create_unix_socket
        server4 = UNIXServer.open('/tmp/sock')  # Socket to listen
        loop{                   # Servers run forever
          Thread.start(server4.accept) do |client|
          string = client.read
          if string.start_with?('failedtest')
            string.gsub!('failedtest','') 
            @failedarray.push string
          else
            string.gsub!('successtest', '')
            @successarray.push string
          end  
            client.close
          end
        }
      end     
   end
end
