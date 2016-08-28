require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class OperationOnLabeled
      def initialize(label, action, op: :map, **args)
        @op = op
        @action = action
        @label = label
        @args = args
      end

      def call(tracker)
        value = -> (v) do
          to_emit =
            if v.is_a?(LabeledTrackable) && v.label == @label
              v.send(@op, **@args, &@action)
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
