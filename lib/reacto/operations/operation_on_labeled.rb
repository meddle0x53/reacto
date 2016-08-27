require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class OperationOnLabeled
      def initialize(label, action, error: nil, close: nil, op: :map)
        @op = op
        @action = action
        @error = error
        @close = close
        @label = label
      end

      def call(tracker)
        value = -> (v) do
          to_emit =
            if v.is_a?(LabeledTrackable) && v.label == @label
              if @op == :map
                v.map(error: @error, close: @close, &@action)
              else
                v.send(@op, &@action)
              end
            else
              v
            end

          tracker.on_value(to_emit)
        end

        Subscriptions::OperationSubscription.new(tracker, value: value)
      end
    end
  end
end
