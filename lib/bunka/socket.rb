require 'socket'

class Bunka
  class << self
    def create_failed_unix_socket
      failed_server = UNIXServer.new('/tmp/failed_sock')  # Socket to listen
      loop do
        Thread.start(failed_server.accept) do |client|
          testresult = client.read
          @failedarray.push testresult
          client.close
        end
      end
    end
    
    def create_success_unix_socket
      success_server = UNIXServer.new('/tmp/success_sock')  # Socket to listen
      loop do
        Thread.start(success_server.accept) do |client|
          testresult = client.read
          @successarray.push testresult
          client.close
        end
      end
    end

    def socket_delete
      File.delete('/tmp/failed_sock') if File.exist?('/tmp/failed_sock')
      File.delete('/tmp/success_sock') if File.exist?('/tmp/success_sock')
    end

    def fill_failedarray
      @testresult.gsub!('failedtest', '')
      @failedarray.push @testresult
    end

    def fill_successarray
      @testresult.gsub!('successtest', '')
      @successarray.push @testresult
    end

    def fill_timeoutarray
      @testresult.gsub!('timeouttest', '')
      @timeoutarray.push @testresult
    end
  end
end
