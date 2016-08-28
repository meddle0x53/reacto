require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class ChunkWhile
      def initialize(func, executor: nil)
        @func = func
        @executor = executor
      end

      def call(tracker)
        current_data = []
        prev_value = NO_VALUE

        value = ->(v) do
          if prev_value == NO_VALUE
            prev_value = v
            current_data << v

            return
          end

          should_continue = @func.call(prev_value, v)
          prev_value = v

          unless should_continue
            flush_current(tracker, current_data)
            current_data = []
          end
          current_data << v
        end

        error = ->(e) do
          flush_current(tracker, current_data)
          tracker.on_error(e)
        end

        close = ->() do
          flush_current(tracker, current_data)
          tracker.on_close
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value, close: close, error: error
        )
      end

      def flush_current(tracker, current_data)
        tracker.on_value(
          Trackable.enumerable(current_data, executor: @executor)
        )
      end
    end
  end
end
