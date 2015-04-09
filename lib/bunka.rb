require 'parallel'
require 'bunka/bunka'
require 'bunka/chef'
require 'bunka/ssh'
require 'bunka/serverspec'
require 'bunka/socket'

class Bunka
  class << self
    def test(command, query, timeout_interval, verbose_success,
             invert, sequential, threads, file = nil)
      @command = command
      @invert = invert
      @query = query
      @sequential = sequential
      @threads = sequential ? 1 : threads
      @timeout_interval = timeout_interval
      @verbose_success = verbose_success
      @file = file ? File.expand_path(file) : nil
      parallel_exec
    end

    def testserverspec(serverspecfile, query, timeout_interval,
                       verbose_success, invert, sequential,
                       processes, file)
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
      create_sockets
      serverspecsetup
      print_summary
      socket_delete
      puts Time.now - start
    end

<<<<<<< HEAD
    def findfile(path, query, timeout_interval, verbose_success,
                 invert, sequential, threads, file = nil)
      @command = "test -f '#{path}'"
=======
    def testfile(path, query, timeout_interval, verbose_success, invert, sequential, threads, file = nil)
      @command = "find . -name '#{path}' | egrep '.*'"
>>>>>>> 9edb5a7... File methode finished
      @invert = invert
      @query = query
      @sequential = sequential
      @threads = sequential ? 1 : threads
      @timeout_interval = timeout_interval
      @verbose_success = verbose_success
      @file = file ? File.expand_path(file) : nil
<<<<<<< HEAD
      parallel_exec
    end

    def finddir(path, query, timeout_interval, verbose_success,
                 invert, sequential, threads, file = nil)
      @command = "test -d '#{path}'"
      @invert = invert
      @query = query
      @sequential = sequential
      @threads = sequential ? 1 : threads
      @timeout_interval = timeout_interval
      @verbose_success = verbose_success
      @file = file ? File.expand_path(file) : nil
      parallel_exec
    end
    
    def md5sum(path, checksum, query, timeout_interval, verbose_success,
               invert, sequential, threads, file = nil)
      @command = "md5sum -c - <<<'#{checksum}  #{path}'"
      @invert = invert
      @query = query
      @sequential = sequential
      @threads = sequential ? 1 : threads
      @timeout_interval = timeout_interval
      @verbose_success = verbose_success
      @file = file ? File.expand_path(file) : nil
      parallel_exec
    end

    def port(port, query, timeout_interval, verbose_success,
             invert, sequential, threads, file = nil)
      @command = "netstat -anp |grep ':#{port}'"
      @invert = invert
      @query = query
      @sequential = sequential
      @threads = sequential ? 1 : threads
      @timeout_interval = timeout_interval
      @verbose_success = verbose_success
      @file = file ? File.expand_path(file) : nil
      parallel_exec
    end

    def service(name, query, timeout_interval, verbose_success,
                invert, sequential, threads, file = nil)
      @command = "service #{name} status"
      @invert = invert
      @query = query
      @sequential = sequential
      @threads = sequential ? 1 : threads
      @timeout_interval = timeout_interval
      @verbose_success = verbose_success
      @file = file ? File.expand_path(file) : nil
      parallel_exec
=======

      Parallel.map(nodes, in_threads: @threads) do |fqdn|
        execute_query fqdn
      end

      print_summary
>>>>>>> 9edb5a7... File methode finished
    end
  end
end
