module Reacto
  module Behaviours
    module_function

    def with_close_and_error(tracker, &block)
      begin
        yield tracker if block_given?
        tracker.on_close if tracker.subscribed?
      rescue
        tracker.on_error(error) if tracker.subscribed?
      end
    end

    def single_tracker_value(tracker, value)
      with_close_and_error(tracker) do |subscriber|
        subscriber.on_value(value) if subscriber.subscribed?
      end
    end

    def single_value(value)
      lambda do |tracker|
        with_close_and_error(tracker) do |subscriber|
          subscriber.on_value(value) if subscriber.subscribed?
        end
      end
    end
  end
end
