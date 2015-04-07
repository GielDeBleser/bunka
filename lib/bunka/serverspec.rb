require 'rspec'
require 'bunka/helpers'
require 'pry'
require 'socket'

class Bunka
  class << self
    def serverspecsetup

      file_control

      RSpec.configure do |c|
        c.output_stream = nil
      end
      @hosts.each_slice(@processes).each do |h|
      Parallel.map(h, in_processes: @processes) do |hostx|
        ENV['TARGET_HOST'] = hostx
        @hostx = hostx
        config = RSpec.configuration
        formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)
        # create reporter with json formatter
        reporter =  RSpec::Core::Reporter.new(config)
        config.instance_variable_set(:@reporter, reporter)
        # internal hack
        # api may not be stable, make sure lock down Rspec version
        loader = config.send(:formatter_loader)
        notifications = loader.send(
          :notifications_for, 
          RSpec::Core::Formatters::JsonFormatter
        )
        reporter.register_listener(formatter, *notifications)
        begin
          RSpec::Core::Runner.run([@serverspecfile])
        rescue RuntimeError
          puts 'Serverspec failed'
        end
        @hash = formatter.output_hash
        RSpec.clear_examples

        parse_spec_output
        end
      end
    end

    def file_control
      
      @file = File.expand_path(@file)
      @serverspecfile = File.expand_path(@serverspecfile)
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

    def parse_spec_output
      c = UNIXSocket.open("/tmp/sock")
      
      @failstatus = false
      @successstatus = false

      @hash[:examples].each do |x|
        if x[:status] == 'failed'
          @failstatus = true
          c.write('failedtest' + "\n" +  @hostx + ': ' + x[:full_description])
          puts @failedarray
        elsif x[:status] == 'passed'
          c.write('successtest' + "\n" + @hostx + ': ' + x[:full_description])
        end
      end

      c.close

      if !invert? && @failstatus == true
        failedspec
      elsif invert? && @failstatus == false
        failedspec
      else
        successspec
      end
    end
  end
end
