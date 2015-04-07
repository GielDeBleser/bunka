require 'rspec'
require 'bunka/helpers'
require 'pry'
require 'socket'

class Bunka
  class << self
    def serverspecsetup
      file_control
      @hosts.each_slice(@processes).each do |h|
        Parallel.map(h, in_processes: @processes) do |hostx|
          rspec_config
          ENV['TARGET_HOST'] = hostx
          @hostx = hostx
          config
          formatter
          # create reporter with json formatter
          reporter
          config.instance_variable_set(:@reporter, reporter)
          # internal hack
          # api may not be stable, make sure lock down Rspec version
          loader
          notifications
          reporter.register_listener(formatter, *notifications)
          run_tests
          @hash = formatter.output_hash
          parse_spec_output_to_socket unless @timedoutbool == true
        end
      end
    end

    def hash
      @hash ||= formatter.output_hash
    end

    def config
      @config ||= RSpec.configuration
    end

    def formatter
      @formatter ||= RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)
    end

    def reporter
      @reporter ||=  RSpec::Core::Reporter.new(config)
    end

    def loader
      @loader ||= config.send(:formatter_loader)
    end

    def notifications
      @notifications ||= loader.send(
        :notifications_for,
        RSpec::Core::Formatters::JsonFormatter
        )
    end

    def run_tests
      begin
        timeout @timeout_interval do
          Net::SSH.start(@hostx, 'root', paranoid: false, forward_agent: true)
        end
        RSpec::Core::Runner.run([@serverspecfile])
        rescue TimeoutError, Errno::ETIMEDOUT, SocketError, Errno::EHOSTUNREACH
          timeoutspec
          @timedoutbool = true
          fill_timeout_array
        rescue RuntimeError
          puts 'Serverspec failed'
        end
    end

    def file_control
      if @file
        if File.exist?(@file)
          @hosts = File.readlines(@file).each { |l| l.chomp! }
        else
          puts 'Serverfile not found'
          exit
        end
      elsif @query
        @hosts = knife_search @query
      else
        puts 'Wrong querry'
        exit
      end
      if File.exist?(@serverspecfile) == false
        puts 'Serverspecfile not found'
        exit
      end
    end

    def parse_spec_output_to_socket
      c = UNIXSocket.open('/tmp/sock')
      @failstatus = false
      @successstatus = false
      hash[:examples].each do |x|
        if x[:status] == 'failed'
          @failstatus = true
          c.write('failedtest' + "\n" +  @hostx + ': ' + x[:full_description])
        elsif x[:status] == 'passed'
          c.write('successtest' + "\n" + @hostx + ': ' + x[:full_description])
        end
      end
      check_invert
    end

    def check_invert
      if !invert? && @failstatus == true
        failedspec
      elsif invert? && @failstatus == false
        failedspec
      else
        successspec
      end
    end

    def fill_timeout_array
      c = UNIXSocket.open('/tmp/sock')
      c.write('timeouttest' + ' - ' +  @hostx)
    end

    def rspec_config
      RSpec.configure do |c|
        c.output_stream = nil
      end
    end
  end
end
