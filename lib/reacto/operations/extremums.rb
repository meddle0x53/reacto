require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Extremums
      AVAILABLE_TYPES = %i(min max minmax)

      def initialize(action: nil, by: nil, type: :max)
        unless AVAILABLE_TYPES.include?(type)
          raise ArgumentError.new(
            "Type not supported, expecting one of #{AVAILABLE_TYPES.join(', ')}"
          )
        end

        @action = action
        @by = by
        @type = type
      end

      def call(tracker)
        buffer = []

        behaviour = -> (v) do
          buffer << v
        end

        error = -> (e) do
          emit_values(tracker, buffer)
          tracker.on_error(e)
        end

        close = -> () do
          emit_values(tracker, buffer)
          tracker.on_close
        end

        Subscriptions::OperationSubscription.new(
          tracker, error: error, value: behaviour, close: close
        )
      end

      def emit_values(tracker, buffer)
        values =
          if @by
            buffer.send("#{@type.to_s}_by", &@by)
          else
            buffer.send(@type, &@action)
          end

        Array(values).each { |val| tracker.on_value(val) }
      end
    end
  end
end
