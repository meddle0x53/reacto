require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class MapLabel
      def initialize(label, mapping, error: nil, close: nil)
        @mapping = mapping
        @error = error
        @close = close
        @label = label
      end

      def call(tracker)
        value = -> (v) do
          to_emit =
            if v.is_a?(LabeledTrackable) && v.label == @label
              v.map(@mapping, error: @error, close: @close)
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
