require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Flatten
      def call(tracker)
        behaviour = -> (value) do
          if value.kind_of?(Array)
            value.flatten.each do |sub_value|
              tracker.on_value(sub_value)
            end
          else
            tracker.on_value(value)
          end
        end

        Subscriptions::OperationSubscription.new(tracker, value: behaviour)
      end
    end
  end
end
