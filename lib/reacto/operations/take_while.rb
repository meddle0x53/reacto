require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class TakeWhile
      def initialize(predicate)
        @predicate = predicate
      end

      def call(tracker)
        closed = false

        behaviour = -> (value) do
          return if closed

          if @predicate.call(value)
            tracker.on_value(value)
          else
            closed = true
            tracker.on_close
          end
        end

        Subscriptions::OperationSubscription.new(tracker, value: behaviour)
      end
    end
  end
end
