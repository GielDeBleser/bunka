require 'rspec'
require 'bunka/helpers'
require 'pry'
require 'socket'

class Bunka
  class << self
    def serverspecsetup
      
      # Can be done with bunka.nodes if also include knife search
      if File.exist?(ENV['HOME']+@file)
        @hosts = File.readlines(ENV['HOME']+@file).each {|l| l.chomp!}
      else
        puts 'Serverfile not found'
        exit
      end
      RSpec.configure do |c|
       c.output_stream = nil
      end
       threads = @threads 
       Parallel.map(@hosts, in_processes: threads) do |hostx|
          RSpec::Core::Configuration#reset
          ENV['TARGET_HOST'] = hostx
          config = RSpec.configuration
          formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)
          # create reporter with json formatter
          reporter =  RSpec::Core::Reporter.new(config)
          config.instance_variable_set(:@reporter, reporter)
          # internal hack
          # api may not be stable, make sure lock down Rspec version
          loader = config.send(:formatter_loader)
          notifications = loader.send(:notifications_for, RSpec::Core::Formatters::JsonFormatter)
          reporter.register_listener(formatter, *notifications)
          begin
            RSpec::Core::Runner.run([ENV['HOME'] + @serverspecfile])
          rescue RuntimeError
            puts 'Serverspec failed'
          end
          @hash = formatter.output_hash
          RSpec.clear_examples

          f = TCPSocket.open('localhost', 2000)
          s = TCPSocket.open('localhost', 2001)
         @failstatus = false
         @successstatus = false 

          @hash[:examples].each do |x|
            if x[:status] == 'failed'
              @failstatus = true
              f.write("\n"+hostx + ': ' + x[:full_description])
            elsif x[:status] == 'passed'
              s.write("\n" + hostx + ': ' + x[:full_description])
            end
          end

          if !invert? && @failstatus == true
            failedspec
          elsif invert? && @failstatus == false
            failedspec
          else
            successspec
          end

         f.close 
         s.close
         
        end 
      end
    end
  end
