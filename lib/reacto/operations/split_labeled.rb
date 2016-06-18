require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class SplitLabeled
      def initialize(label, chose_label, executor = nil)
        @label = label
        @chose_label = chose_label
        @executor = executor
      end

      def call(tracker)
        value = -> (v) do
          if v.is_a?(LabeledTrackable) && v.label == @label
            action = -> (labeled_trackable) do
              tracker.on_value(labeled_trackable)
            end

            v.group_by_label(@chose_label, executor: @executor)
              .on(value: action)
          else
            tracker.on_value(v)
          end
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value
        )
      end
    end
  end
end
