require 'pry'

class Bunka
	class << self
			def initializerspec
				@errors = []
				@status = []
				@failed = 0
				@passed = 0
				@pending = 0	
				
				if File.exist?(ENV['HOME']+'/servers/sandboxservers')
					@hosts = File.readlines(ENV['HOME']+'/servers/sandboxservers').each {|l| l.chomp!}
				else
					puts 'Serverfile not found'
					exit
				end
				RSpec.configure { |c| c.output_stream = nil }		
				@hosts.each do |host|
					ENV['TARGET_HOST'] = host
					binding.pry
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
			

					@h = formatter.output_hash
					RSpec.clear_examples		
					@h[:examples].each do |x|
						if x[:status] == 'failed'
							@errors << (host + ':  ' + x[:full_description].red)
						end
					end
					print_symbol_results

			end
		end
	end
end
