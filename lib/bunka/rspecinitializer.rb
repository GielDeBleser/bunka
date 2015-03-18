
class Bunka
	class << self
			def initializerspec
				if File.exist?(ENV['HOME']+'/servers/sandboxservers')
					@hosts = File.readlines(ENV['HOME']+'/servers/sandboxservers').each {|l| l.chomp!}
				else
					puts 'Serverfile not found'
					exit
				end
				
				RSpec.configure { |c| c.output_stream = nil }		
				@hosts.each do |host|
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
    		
					ENV['TARGET_HOST'] = host
					begin
						RSpec::Core::Runner.run([ENV['HOME'] + @serverspecfile])	
					rescue RuntimeError
  					puts 'Serverspec failed'
					end
				end
			end
	end
end
