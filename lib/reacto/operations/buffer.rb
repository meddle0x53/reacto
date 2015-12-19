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
          tracker.on_value(@buffer) unless @buffer.empty?
          tracker.on_close
        end
        error = lambda do |e|
          tracker.on_value(@buffer) unless @buffer.empty?
          tracker.on_error(e)
        end
        value = if !@count.nil? && @delay.nil?
                  count_buffer_behaviour(tracker)
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
    end
  end
end

