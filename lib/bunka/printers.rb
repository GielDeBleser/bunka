require 'colorize'

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
      @failedarray.reject! &:empty?
      @successarray.reject! &:empty?
      @failed = @failedarray.count
      @success = @successarray.count - @failedarray.count
      @timedout = @timeoutarray.count
      @total = @failed + @success + @timedout
      specinvert
      verbose_success? ? print_successspec_stream : print_failedspec_stream
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
      return unless invert?
      @dummyarray, @failedarray, @successarray = @failedarray, @successarray, @dummyarray
      @dummyint = @failed
      @failed = @success
      @success =  @dummyint
    end

    def print_summary
      @serverspecfile ? print_spec_output : print_output
      puts "\n---------------------------------------\n"
      @serverspecfile ? print_spec_counts : print_counts
    end

    def print_output
      print "\n"
      print_timeout_stream
      print_failed_stream
      print_success_stream if verbose_success?
    end

    def print_spec_output
      if !verbose_success?
        puts "\n\nErrors: ".red
      else
        puts "\n\nSuccesses: ".green
      end
      print_spec_streams
      return unless  @timeoutarray.count > 0
      puts "\nTimed out or unresolved nodes: \n".yellow
      print_timeoutspec_stream
    end

    def print_counts
      puts "#{'Success:'.green} #{success_output_stream.count}"
      puts "#{'Timed out or does not resolve:'.yellow} " \
        "#{timeout_output_stream.count}"
      puts "#{'Failed:'.red} #{failed_output_stream.count}"
      puts "#{'Total:'.blue} #{success_output_stream.count \
        timeout_output_stream.count \
          failed_output_stream.count}"
    end

    def print_spec_counts
      puts "#{'Success:'.green} " + @success.to_s
      puts "#{'Timed out or does not resolve:'.yellow} " + @timedout.to_s
      puts "#{'Failed:'.red} " + @failed.to_s
      puts "#{'Total:'.blue} " + @total.to_s + "\n"
    end
  end
end
