require 'serverspec'
require 'rspec/core/rake_task'
require 'rake'
require 'bunka/rake_spec'
require 'bunka/spec_helper'
require 'pry'
require 'serverspecprinter'

class Bunka
	class << self

		def serverspecsetup
			hosts = File.readlines(ENV['HOME']+'/servers/sandboxservers').each {|l| l.chomp!}
  		#hosts.each do |host|
    	#	short_name = host.split('.')[0]		


			
			hosts.each do |host|
					
    		RSpec::Core::RakeTask.new('spec:'+host) do |t|
      		t.pattern = ENV['HOME']+ @serverspecfile
					t.fail_on_error = false
				end
					puts "Run serverspec to #{host}"
					ENV['TARGET_HOST'] = host
					begin
  					Rake::Task['spec:'+ host].execute
						rescue RuntimeError
  						puts 'this is failed'
					end
			end
		end
	end
end

