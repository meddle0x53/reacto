require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Append
      attr_reader :to_append

      def initialize(to_append, condition: nil)
        @to_append = to_append
        @condition = condition
      end

      def call(tracker)
        empty = true

        on_value =
          if @condition == :source_empty
            -> (v) do
              empty = false if empty
              tracker.on_value(v)
            end
          else
            tracker.method(:on_value)
          end

        on_close = -> () do
          if (@condition == :source_empty && empty) || @condition.nil?
            if to_append.respond_to? :each
              to_append.each { |v| tracker.on_value(v) }
            else
              tracker.on_value(to_append)
            end
          end

          tracker.on_close
        end

        Subscriptions::OperationSubscription.new(
          tracker, close: on_close, value: on_value
        )
      end
    end
  end
end

