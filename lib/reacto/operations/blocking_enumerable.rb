require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class BlockingEnumerable
      def initialize(method_name, block)
        @method_name = method_name
        @block = block
      end

      def call(tracker)
        data = []

        value = -> (val) { data << val }
        close = -> do
          emit(tracker, data)
          tracker.on_close
        end
        error = ->(e) do
          emit(tracker, data)
          tracker.on_error(e)
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value, error: error, close: close
        )
      end

      def emit(tracker, data)
        result = data.send(@method_name, &@block)

        if result.is_a?(Enumerable)
          result.each { |value| tracker.on_value(value) }
        else
          tracker.on_value(result)
        end
      end
    end
  end
end
