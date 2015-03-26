require 'pry'
require 'bunka/helpers'

class Bunka
  class << self
    def initializerspec
      
      # Can be done with bunka.nodes if also include knife search
      if File.exist?(ENV['HOME']+@file)
        @hosts = File.readlines(ENV['HOME']+@file).each {|l| l.chomp!}
      else
        puts 'Serverfile not found'
        exit
      end
      @pid = 0
      RSpec.configure do |c|
       c.output_stream = nil
      end
        threads = @threads
        @hosts.each_slice(threads).to_a.each do |h|
        Parallel.map(h, in_processes: threads) do |hostx|
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
          @hash[:examples].each do |x|
            if x[:status] == 'failed'
               failed x[:full_description]
               puts @pid
            elsif x[:status] == 'passed'
              succeeded x[:full_description]
            else
              timed_out x[:full_description]
            end
          end
        @pid = @pid+1
        end 
      end
    end
  end
end
