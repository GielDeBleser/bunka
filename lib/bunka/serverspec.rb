require 'rspec/core/rake_task'
require 'rake'
#require 'bunka/serverspecprinter'
require 'rspec'
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
			@status = []
			@failed = 0
			@passed = 0
			@pending = 0
			
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
  			#	Rake::Task['spec:'+ host].execute
				RSpec::Core::Runner.run([ENV['HOME'] + @serverspecfile])	
			rescue RuntimeError
  			puts 'Serverspec failed'
			end
				
			@h = formatter.output_hash
			@h[:examples].each do |x|
				if x[:status] == 'failed'
					@errors << (host + ':  ' + x[:full_description].red)
				end
			end
			puts "\n"		
			@h[:examples].each do |x|
				if 	x[:status] == 'failed'
					@status << 'F'.red
					@failed = @failed + 1	
				end
				if	x[:status] == 'passed'
					@status << '.'.green	
					@passed = @passed + 1	
				end
				if 	x[:status] == 'pending'
					@status << 'P'.yellow	
					@pending = @pending + 1	
				end	
			end	
		RSpec.clear_examples		
		end
			@status.each do |x|
				print x
			end
			@totaltest = @failed + @passed + @pending
			puts "\n"
			puts "\n"+'Total tests: '.blue + @totaltest.to_s
			puts 'Failed: '.red + @failed.to_s
			puts 'Passed: '.green + @passed.to_s
			puts 'Pending: '.yellow + @pending.to_s
			puts "\n"+'Errors:'.red
			puts @errors 
			puts "\n"+'Duration:' + @h[:summary][:duration].to_s
		end
	end
end
