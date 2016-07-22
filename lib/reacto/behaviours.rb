module Reacto
  module Behaviours
    module_function

    def with_close_and_error(tracker, &block)
      begin
        yield tracker if block_given?
        tracker.on_close if tracker.subscribed?
      rescue StandardError => error
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

    def enumerable(enumerable_value)
      ->(tracker) do
        begin
          enumerable_value.each do |val|
            break unless tracker.subscribed?
            tracker.on_value(val)
          end

          tracker.on_close if tracker.subscribed?
        rescue => error
          tracker.on_error(error) if tracker.subscribed?
        end
      end
    end

    def integers_enumerator
      Enumerator.new do |yielder|
        n = 0
        loop do
          yielder << n
          n = n + 1
        end
      end
    end

    def array_repeat_enumerator(array)
      size = array.size

      Enumerator.new do |yielder|
        n = 0
        loop do
          yielder.yield array[n % size]
          n = n + 1
        end
      end
    end
  end
end
