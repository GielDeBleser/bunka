require 'socket'
require 'pry'

class Bunka
  class << self
    def create_unix_socket
      server4 = UNIXServer.new('/tmp/sock')  # Socket to listen
      loop do                 # Servers run forever
        Thread.start(server4.accept) do |client|
          string = client.read
          if string.start_with?('failedtest')
            string.gsub!('failedtest', '')
            @failedarray.push string
          elsif string.start_with?('successtest')
            string.gsub!('successtest', '')
            @successarray.push string
          else
            string.gsub!('timeouttest', '')
            @timeoutarray.push string
          end
          client.close
        end
      end
    end

    def socket_delete
      File.delete('/tmp/sock') if File.exist?('/tmp/sock')
    end
  end
end
