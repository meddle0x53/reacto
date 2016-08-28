require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class SliceWhen
      def initialize(predicate)
        @predicate = predicate
      end

      def call(tracker)
        previous = NO_VALUE
        buffer = []

        behaviour = -> (val) do
          if previous != NO_VALUE && @predicate.call(previous, val)
            tracker.on_value(Trackable.enumerable(buffer))
            buffer = []
          end

          buffer << val
          previous = val
        end

        error = -> (e) do
          tracker.on_value(Trackable.enumerable(buffer)) unless buffer.empty?
          tracker.on_error(e)
        end

        close = -> () do
          tracker.on_value(Trackable.enumerable(buffer)) unless buffer.empty?
          tracker.on_close
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: behaviour, error: error, close: close
        )
      end
    end
  end
end
