require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Slice
      TYPES = %i(before after)

      def initialize(predicate, type: :after)
        unless TYPES.include?(type)
          raise ArgumentError.new(
            "Type #{type} not supported. " \
            "Supported types are #{TYPES.join(', ')}"
          )
        end

        @type = type
        @predicate = predicate
      end

      def call(tracker)
        buffer = []

        behaviour = -> (val) do
          buffer << val if @type == :after

          if @predicate.call(val)
            tracker.on_value(Trackable.enumerable(buffer))
            buffer = []
          end

          buffer << val if @type == :before
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
