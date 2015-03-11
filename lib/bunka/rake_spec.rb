require 'serverspec'
require 'rspec/core/rake_task'
require 'rake'

class bunka
	class << self
		def rake_spec
			begin
  			Rake::Task['spec'].invoke
			rescue RuntimeError
  			exit 1
			end
		end
	end
end
