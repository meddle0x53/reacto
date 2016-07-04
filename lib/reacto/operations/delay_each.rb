require 'ostruct'
require 'concurrent'

require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class DelayEach
      class TaskObserver
        def initialize(tracker)
          @tracker = tracker
        end
        def update(time, result, e)
          if e
            @tracker.on_error(e) unless e.is_a?(Concurrent::TimeoutError)
          end
        end
      end

      def initialize(delay)
        @delay = delay
        @queue = []
      end

      def call(tracker)
        close = lambda do
          @queue << OpenStruct.new(type: :close)
          delay_task(tracker)
        end

        error = lambda do |e|
          @queue << OpenStruct.new(error: e, type: :error)
          delay_task(tracker)
        end

        value = lambda do |v|
          @queue << OpenStruct.new(value: v, type: :value)
          delay_task(tracker)
        end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: value,
          close: close,
          error: error
        )
      end

      private

      def delay_task(tracker)
        return if @task

        @task = Concurrent::TimerTask.new(execution_interval: @delay) do
          notification = @queue.shift

          return unless notification

          if notification.type == :value
            tracker.on_value(notification.value)
          elsif notification.type == :error
            tracker.on_error(notification.error)
            @task.shutdown
          else
            tracker.on_close
            @task.shutdown
          end
        end
        @task.add_observer(TaskObserver.new(tracker))

        @task.execute
      end
    end
  end
end
