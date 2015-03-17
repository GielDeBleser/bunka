require 'rspec/core/rake_task'
require 'rake'
#require 'bunka/serverspecprinter'
require 'rspec'
require 'pry'
require 'colorize'

class Bunka
	class << self

		def serverspecsetup
			@hosts = File.readlines(ENV['HOME']+'/servers/sandboxservers').each {|l| l.chomp!}
  		#hosts.each do |host|
    	#	short_name = host.split('.')[0]		


			hosts.each do |host|
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
    		
				RSpec::Core::RakeTask.new('spec:'+host) do |t|
      		t.pattern = ENV['HOME']+ @serverspecfile
					t.fail_on_error = false
					t.verbose = false
				end
					ENV['TARGET_HOST'] = host
					begin
  				#	Rake::Task['spec:'+ host].execute
					RSpec::Core::Runner.run([ENV['HOME'] + @serverspecfile])
						rescue RuntimeError
  						puts 'Serverspec failed'
					end
				h = formatter.output_hash
				
				puts "\n"		
				
				#binding.pry			
			
				if 	h[:examples][0][:status] == 'failed'
					puts 'F'.red	
				elsif	h[:examples][0][:status] == 'passed'
					puts '.'.green	
				else 	h[:examples][0][:status] == 'pending'
					puts 'P'.yellow	
				end				
			end
			print_results(h)
		end
	end
end
