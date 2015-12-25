require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Uniq
      def passed
        @passed ||= []
      end

      def call(tracker)
        value = lambda do |v|
          unless passed.include?(v)
            passed << v
            tracker.on_value(v)
          end
        end

        Subscriptions::OperationSubscription.new(tracker, value: value)
      end
    end
  end
end
