
class Bunka
	class << self
		def print_symbol_results
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
		end
		def print_number_results
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

