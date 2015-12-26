require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Uniq
      def passed
        @passed ||= {}
      end

      def call(tracker)
        value = lambda do |v|
          unless passed[v]
            passed[v] = true
            tracker.on_value(v)
          end
        end

        Subscriptions::OperationSubscription.new(tracker, value: value)
      end
    end
  end
end
