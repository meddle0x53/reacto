require 'concurrent'
require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Throttle
      def initialize(delay)
        @delay = delay
        @last = NO_VALUE
        @ready = false
        @error = NO_VALUE
        @close = false
      end

      def call(tracker)
        close = -> () { @close = true }
        error = -> (e) do
          delay_task(tracker) unless @ready
          @error = e
        end
        value = -> (v) do
          delay_task(tracker) unless @ready
          @last = v
        end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: value,
          close: close,
          error: error
        )
      end

      private

      def finish
        @task.shutdown if @task
      end

      def delay_task(tracker)
        @task = Concurrent::TimerTask.new(execution_interval: @delay) do
          if @error != NO_VALUE
            tracker.on_error(@error)
            finish
          elsif @close
            tracker.on_close
            finish
          elsif @last != NO_VALUE
            tracker.on_value(@last)
            @last = NO_VALUE
          end
        end
        @task.execute
        @ready = true
      end
    end
  end
end
