require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Select
      def initialize(filter)
        @filter = filter
      end

      def call(tracker)
        on_value = lambda do |v|
          if @filter.call(v)
            tracker.on_value(v)
          end
        end

        Subscriptions::OperationSubscription.new(tracker, value: on_value)
      end
    end
  end
end

