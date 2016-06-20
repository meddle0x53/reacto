require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class FlatMapLabel
      def initialize(label, transform)
        @transform = transform
        @label = label
      end

      def call(tracker)
        value = -> (v) do
          to_emit =
            if v.is_a?(LabeledTrackable) && v.label == @label
              v.flat_map(@transform)
            else
              v
            end

          tracker.on_value(to_emit)
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value
        )
      end
    end
  end
end
