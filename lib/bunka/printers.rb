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

    def print_spec_streams
      @failedarray.reject! { |c| c.empty? }
      @successarray.reject! { |c| c.empty? }
      specinvert

      if verbose_success?
        print_successspec_stream
      else
        print_failedspec_stream
      end
    end

    def print_failedspec_stream
      @failedarray.each do |output|
        puts output.red
      end
    end

    def print_successspec_stream
      @successarray.each do |output|
        puts output.green
      end
    end
    
    def print_timeoutspec_stream
      @timeoutarray.each do |output|
        puts output.yellow
      end
    end

    def specinvert
      if invert?
        @dummy = @failedarray
        @failedarray = @successarray
        @successarray = @dummy
      end
    end

    def print_summary
      print "\n"

      puts @timeoutarray.inspect

      print_timeout_stream
      if @serverspecfile && !verbose_success?
        puts "\nErrors: ".red
      else
        puts "\nSuccesses: ".green if @serverspecfile
      end
      print_spec_streams if @serverspecfile
      if @serverspecfile && @timeoutarray.count > 0
        puts "\n" + 'Timed out or unresolved nodes: '.yellow
        print_timeoutspec_stream
      end
      print_failed_stream
      print_success_stream if verbose_success?

      puts "\n---------------------------------------\n"

      if @serverspecfile
        @failed = @failedarray.count
        @success = @successarray.count
        @timedout = @timeoutarray.count
        @total = @failed + @success + @timedout
      end

      if @serverspecfile
        puts "#{'Success'.green}: " + @success.to_s
      else
        puts "#{'Success'.green}: #{success_output_stream.count}"
      end

      if @serverspecfile
        puts "#{'Timed out or does not resolve'.yellow}: " + @timedout.to_s
      else
        puts "#{'Timed out or does not resolve'.yellow}: #{timeout_output_stream.count}"
      end
      if @serverspecfile
        puts "#{'Failed: '.red}" + @failed.to_s
      else
        puts "#{'Failed'.red}: #{failed_output_stream.count}"
      end
      if @serverspecfile
        puts "#{'Total'.blue}: " + @total.to_s
      else
        puts "#{'Total'.blue}: #{success_output_stream.count + timeout_output_stream.count + failed_output_stream.count}"
      end
      puts "\n"
    end
  end
end
