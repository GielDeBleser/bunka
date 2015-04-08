require 'parallel'
require 'bunka/bunka'
require 'bunka/chef'
require 'bunka/ssh'
require 'bunka/serverspec'
require 'bunka/socket'

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
      @file = file ? File.expand_path(file) : nil

      Parallel.map(nodes, in_threads: @threads) do |fqdn|
        execute_query fqdn
      end

      print_summary
    end

    def testserverspec(serverspecfile, query, timeout_interval, verbose_success, invert, sequential, processes, file)
      @serverspecfile = File.expand_path(serverspecfile)
      @query = query
      @invert = invert
      @sequential = sequential
      @processes = sequential ? 1 : processes
      @timeout_interval = timeout_interval
      @verbose_success = verbose_success
      @file = file ? File.expand_path(file) : nil
      @failedarray = []
      @successarray = []
      @timeoutarray = []

      socket_delete
      start = Time.now
      Thread.new do
        create_failed_unix_socket
      end
      Thread.new do
        create_success_unix_socket
      end
      Thread.new do
        create_timeout_unix_socket
      end
      sleep(2)
      serverspecsetup
      print_summary
      socket_delete
      puts Time.now - start
    end
  end
end
