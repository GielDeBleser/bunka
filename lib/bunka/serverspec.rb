require 'rspec/core/rake_task'
require 'rake'
#require 'bunka/serverspecprinter'
require 'rspec'
require 'pry'
require 'colorize'

class Bunka
	class << self

		def serverspecsetup
			if File.exist?(ENV['HOME']+'/servers/sandboxservers')
			@hosts = File.readlines(ENV['HOME']+'/servers/sandboxservers').each {|l| l.chomp!}
			else
			puts 'Serverfile not found'
			exit
			end
  		@errors = []
			#hosts.each do |host|
    	#	short_name = host.split('.')[0]		

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
				@h = formatter.output_hash
				
				binding.pry
				
				@h[:examples].each do |x|
				if x[:status] == "failed"
				@errors << (host + ':  ' + x[:full_description].red)
				end
				end
				puts "\n"		
				
				#binding.pry
							
				@h[:examples].each do |x|
				if 	x[:status] == 'failed'
					print 'F'.red	
				end
				if	x[:status] == 'passed'
					print '.'.green	
				end
				if 	x[:status] == 'pending'
					print 'P'.yellow	
					end	
				end			
			end
			puts "\n"
			puts "\n"+'Tests:'.green + @h[:summary][:example_count].to_s
			puts 'Failed:'.red + @h[:summary][:failure_count].to_s
			puts 'Pending:'.yellow + @h[:summary][:pending_count].to_s
			puts "\n"+'Errors:'.red
			puts @errors 
			puts "\n"+'Duration:' + @h[:summary][:duration].to_s
		end
	end
end
