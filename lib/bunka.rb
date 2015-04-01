require 'parallel'
require 'bunka/bunka'
require 'bunka/chef'
require 'bunka/helpers'
require 'bunka/printers'
require 'bunka/ssh'
require 'bunka/serverspec'
require 'bunka/socket'
require 'pry'

class Bunka
  class << self
    def test(command, query, timeout_interval, verbose_success, invert, sequential, threads, file = nil)
      @command = command
      @invert = invert
      @query = query
      @sequential = sequential
      @threads = sequential ? 1 : threads
      @timeout_interval = timeout_interval
      @verbose_success = verbose_success
      @file = file

      Parallel.map(nodes, in_threads: @threads) do |fqdn|
        execute_query fqdn
      end

      print_summary
    end

    def testserverspec(serverspecfile, timeout_interval, verbose_success, invert, sequential, threads, file = '/.bunka/servers')
      @serverspecfile = serverspecfile
      @invert = invert
      @sequential = sequential
      @threads = sequential ? 1 : threads
      @timeout_interval = timeout_interval
      @verbose_success = verbose_success
      @file = file

      @failedarray = []
      @successarray = []
      @timeoutarray = []

      Thread.new do
        create_failed_socket
      end
      Thread.new do
        create_success_socket
      end
      sleep(1)
      serverspecsetup
      print_summary
    end
  end
end
