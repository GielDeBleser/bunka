require 'bunka/printers'

class Bunka
  class << self
    def failed(reason)
      failed_output_stream.push reason
      print_fail
    end

    def succeeded(reason)
      success_output_stream.push reason
      print_success
    end

    def timed_out(reason)
      timeout_output_stream.push reason
      print_timeout
    end

    def timeout_output_stream
      @timeout_output_stream ||= []
    end

    def failed_output_stream
      @failed_output_stream ||= []
    end

    def success_output_stream
      @success_output_stream ||= []
    end

    def verbose_success?
      @verbose_success
    end

    def invert?
      @invert
    end

    def failedspec
      print_fail
    end

    def successspec
      print_success
    end

    def timeoutspec
      print_timeout
    end
  end
end
