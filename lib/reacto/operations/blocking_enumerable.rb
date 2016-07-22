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

        value = ->(val) { data << val }
        close = -> do
          tracker.on_value(data.send(@method_name, &@block))
          tracker.on_close
        end
        error = ->(e) do
          tracker.on_value(data.send(@method_name, &@block))
          tracker.on_error(e)
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value, error: error, close: close
        )
      end
    end
  end
end
