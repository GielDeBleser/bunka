require 'serverspec'
require 'rspec/core/rake_task'
require 'rake'
require 'bunka/rake_spec'
require 'bunka/spec_helper'
require 'serverspec'

class Bunka
	class << self

		def serverspecsetup
			hosts = File.readlines(ENV['HOME']+'/servers/sandboxservers').each {|l| l.chomp!}
  		#hosts.each do |host|
    	#	short_name = host.split('.')[0]

    	RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = ENV['HOME']+'/.serverspecfile.rb'
			end
			
			hosts.each do |host|
					puts "Run serverspec to #{host}"
					ENV['TARGET_HOST'] = host
  				Rake::Task['spec'].invoke
			end
		end
	end
end

