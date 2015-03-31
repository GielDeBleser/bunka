require 'colorize'
require 'pry'

class Bunka
  class << self
    def print_fail
      print 'F'.red
    end

    def print_success
      print '.'.green
    end

    def print_timeout
      print '*'.yellow
    end

    def print_failed_stream
      failed_output_stream.each do |output|
        puts output.red
      end
    end
    
    def print_timeout_stream
      timeout_output_stream.each do |output|
        puts output.yellow
      end
    end

    def print_success_stream
      success_output_stream.each do |output|
        puts output.green
      end
    end

    def print_specfailed_stream
      @failedarray.reject! { |c| c.empty? }
      @successarray.reject! { |c| c.empty? }
      @failedarray.each do |output|
        puts output.red
      end
    end


    def print_summary
      print "\n"
      print_timeout_stream
      puts "\nErrors: ".red if @serverspecfile
      print_specfailed_stream if @serverspecfile
      print_failed_stream 
      print_success_stream if verbose_success? 

      puts "\n---------------------------------------\n"
       @success = @hosts.count - @failedarray.count
      if @serverspecfile
      puts "#{'Success'.green}: " + @success.to_s
      else
      puts "#{'Success'.green}: #{success_output_stream.count}"
      end
      puts "#{'Timed out or does not resolve'.yellow}: #{timeout_output_stream.count}"
      if @serverspecfile
       puts "#{'Failed: '.red}" + @failedarray.count.to_s
      else 
       puts "#{'Failed'.red}: #{failed_output_stream.count}"
      end
      if @serverspecfile
      puts "#{'Total'.blue}: " + (@failedarray.count + @success).to_s 
      else
      puts "#{'Total'.blue}: #{success_output_stream.count + timeout_output_stream.count + failed_output_stream.count}"
      end
      puts "\n"
    end
  end
end
