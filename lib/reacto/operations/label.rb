require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Label
      def initialize(chose_label, executor = nil)
        @chose_label = chose_label
        @executor = executor

        @labeled_values = {}
      end

      def call(tracker)
        value = lambda do |v|
          label, val = @chose_label.call(v)

          @labeled_values[label] ||= []
          @labeled_values[label] << val
        end

        close = lambda do
          emit_values(tracker)
          tracker.on_close
        end

        error = lambda do |err|
          emit_values(tracker)
          tracker.on_error(err)
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value, error: error, close: close
        )
      end

      def emit_values(tracker)
        @labeled_values.each do |label, values|
          trackable =
            LabeledTrackable.new(label, @executor) do |subscriber|
              values.each { |val| subscriber.on_value(val) }
              subscriber.on_close
            end
          tracker.on_value(trackable)
        end
      end
    end
  end
end
