require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Select
      def initialize(filter)
        @filter = filter
      end

      def call(tracker)
        behaviour = -> (v) do
          if @filter.call(v)
            tracker.on_value(v)
          end
        end

        Subscriptions::OperationSubscription.new(tracker, value: behaviour)
      end
    end
  end
end
