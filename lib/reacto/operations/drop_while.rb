require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class DropWhile
      def initialize(predicate)
        @predicate = predicate
      end

      def call(tracker)
        done = false

        behaviour = -> (value) do
          done = !@predicate.call(value) unless done

          tracker.on_value(value) if done
        end

        Subscriptions::OperationSubscription.new(tracker, value: behaviour)
      end
    end
  end
end
