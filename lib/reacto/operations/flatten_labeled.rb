require 'ostruct'

require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class FlattenLabeled
      def initialize(accumulator = nil, initial = NO_VALUE)
        @accumulator = accumulator
        @initial = initial
      end

      def call(tracker)
        value = -> (v) do
          unless v.is_a?(LabeledTrackable)
            tracker.on_error(ArgumentError.new(
              'Trackable#flatten_labeled expects all values emitted by the ' \
              'source Trackable to be LabeledTrackable instances.'
            ))
            return
          end

          labeled_trackable =
            if @accumulator.nil?
              v.first
            else
              v.inject(@initial, &@accumulator).last
            end

          accumulated = []
          labeled_trackable.on(value: ->(val) { accumulated << val })
          tracker.on_value(
            OpenStruct.new({ label: v.label, value: accumulated.first })
          )
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value
        )
      end
    end
  end
end
