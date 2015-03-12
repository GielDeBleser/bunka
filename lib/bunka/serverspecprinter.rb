module RSpec::Core::Notifications
	class ExamplesNotification
    def fully_formatted_failed_examples(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
			formatted ||= "\nNoFailures:\n"
        failure_notifications.each_with_index do |failure, index|
          formatted << failure.fully_formatted(index.next, colorizer)
        end
      formatted
    end	
	end
end
