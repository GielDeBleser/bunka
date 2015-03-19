require 'rspec/core/rake_task'
require 'rake'
require 'bunka/serverspecprinter'
require 'bunka/rspecinitializer'
require 'rspec'
require 'colorize'

class Bunka
	class << self

		def serverspecsetup
			initializerspec	
			#print_number_results
		end
	end
end
