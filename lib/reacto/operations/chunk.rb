require 'reacto/constants'
require 'reacto/behaviours'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Chunk
      def initialize(func, executor: nil)
        @func = func
        @executor = executor
      end

      def call(tracker)
        @current_key = NO_VALUE
        @current_data = []

        value = ->(v) do
          key = @func.call(v)

          if key == nil || key == :_separator
            flush_current!(tracker)
            return
          end

          if key == :_alone
            flush_current!(tracker)
            tracker.on_value(LabeledTrackable.new(
              key, @executor, &Behaviours.single_value(v)
            ))

            return
          end

          if key.to_s.start_with?('_')
            flush_current!(tracker)
            tracker.on_error(RuntimeError.new(
              'symbols beginning with an underscore are reserved'
            ))
            return
          end

          if @current_key == NO_VALUE || @current_key == key
            @current_key = key
            @current_data << v
            return
          end

          flush_current!(tracker)

          @current_key = key
          @current_data = [v]
        end

        error = ->(e) do
          flush_current!(tracker)
          tracker.on_error(e)
        end

        close = ->() do
          flush_current!(tracker)
          tracker.on_close
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value, close: close, error: error
        )
      end

      def flush_current!(tracker)
        if @current_key != NO_VALUE
          tracker.on_value(LabeledTrackable.new(
            @current_key, @executor, &Behaviours.enumerable(@current_data)
          ))
        end

        @current_key = NO_VALUE
        @current_data = []
      end
    end
  end
end
