require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class EachCollect
      def initialize(
        n, reset_action = -> (_) { [] }, on_error: nil, on_close: nil
      )
        @n = n
        @reset_action = reset_action

        @error = on_error
        @close = on_close
      end

      def call(tracker)
        current = []

        error = @error ? @error : ->(e) do
          tracker.on_value(current) unless current.empty?
          tracker.on_error(e)
        end
        close = @close ? @close : ->() do
          tracker.on_value(current) unless current.empty?
          tracker.on_close
        end

        error = error == NO_ACTION ? tracker.method(:on_error) : error
        close = close == NO_ACTION ? tracker.method(:on_close) : close

        behaviour = -> (value) do
          current << value

          if current.size == @n
            tracker.on_value(current)

            current = @reset_action.call(current)
          end
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: behaviour, error: error, close: close
        )
      end
    end
  end
end
