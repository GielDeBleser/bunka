require 'serverspec'
require 'rspec/core/rake_task'
require 'rake'
require 'bunka/rake_spec'

class Bunka
	class << self

		def serverspecsetup
			hosts = File.readlines(ENV['HOME']+'/servers/sandboxservers').each {|l| l.chomp!}
			namespace :spec do
  		task :all => hosts.map {|h| 'spec:' + h.split('.')[0] }
  		hosts.each do |host|
    		short_name = host.split('.')[0]

    	desc "Run serverspec to #{host}"
    	RSpec::Core::RakeTask.new(short_name) do |t|
      ENV['TARGET_HOST'] = host
      t.pattern = @serverspecfile
					end
				end
			end
			start_spec
		end
	end
end

