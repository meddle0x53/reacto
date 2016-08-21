require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class FindIndex
      def initialize(predicate)
        @predicate = predicate
      end

      def call(tracker)
        index = 0

        behaviour = -> (value) do
          found = @predicate.call(value)

          if found
            tracker.on_value(index)
            tracker.on_close
          else
            index += 1
          end
        end

        Subscriptions::OperationSubscription.new(tracker, value: behaviour)
      end
    end
  end
end
