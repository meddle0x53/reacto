require 'reacto/behaviours'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Partition
      def initialize(predicate, executor: nil)
        @predicate = predicate
        @executor = executor
      end

      def call(tracker)
        true_array = []
        false_array = []

        behavior = -> (val) do
          if @predicate.call(val)
            true_array << val
          else
            false_array << val
          end
        end

        error = -> (e) do
          emit_trackables(tracker, true_array, false_array)
          tracker.on_error(e)
        end

        close = -> () do
          emit_trackables(tracker, true_array, false_array)
          tracker.on_close
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: behavior, error: error, close: close
        )
      end

      def emit_trackables(tracker, true_array, false_array)
        true_trackable = LabeledTrackable.new(
          true, @executor, &Behaviours.enumerable(true_array)
        )
        false_trackable = LabeledTrackable.new(
          false, @executor, &Behaviours.enumerable(false_array)
        )

        tracker.on_value(true_trackable)
        tracker.on_value(false_trackable)
      end
    end
  end
end
