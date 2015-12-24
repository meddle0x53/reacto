require 'concurrent'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Buffer
      def initialize(count: nil, delay: nil)
        @count = count
        @delay = delay
        @buffer = []
      end

      def call(tracker)
        close = lambda do
          @task.shutdown if @task

          tracker.on_value(@buffer) unless @buffer.empty?
          tracker.on_close
        end
        error = lambda do |e|
          @task.shutdown if @task

          tracker.on_value(@buffer) unless @buffer.empty?
          tracker.on_error(e)
        end
        value = if !@count.nil? && @delay.nil?
                  count_buffer_behaviour(tracker)
                elsif @count.nil? && !@delay.nil?
                  delay_buffer_behaviour(tracker)
                elsif @count && @delay
                  count_and_delay_buffer_behaviour(tracker)
                else
                  tracker.method(:on_value)
                end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: value,
          close: close,
          error: error
        )
      end

      private

      def count_buffer_behaviour(tracker)
        lambda do |value|
          @buffer << value

          if @buffer.size >= @count
            tracker.on_value(@buffer)
            @buffer = []
          end
        end
      end

      def delay_task(tracker)
        @task = Concurrent::TimerTask.new(execution_interval: @delay) do
          unless @buffer.empty?
            tracker.on_value(@buffer)
            @buffer = []
          end
        end
        @task.execute
      end

      def delay_buffer_behaviour(tracker)
        delay_task(tracker)
        -> (value) { @buffer << value }
      end

      def count_and_delay_buffer_behaviour(tracker)
        delay_task(tracker)
        count_buffer_behaviour(tracker)
      end
    end
  end
end
