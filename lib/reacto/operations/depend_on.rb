require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class DependOn
      def initialize(trackable, key: :data, accumulator: nil)
        @key = key
        @trackable =
          if accumulator.nil?
            trackable.first
          else
            trackable.inject(NO_VALUE, accumulator)
          end

        @lock = Mutex.new

        @close = false
        @error = nil
      end

      def buffer
        @buffer ||= []
      end

      def flush(error = nil)
        unless error.nil?
          @tracker.on_error(error)
          return
        end

        buffer.each do |val|
          @tracker.on_value(
            OpenStruct.new({ value: val }.merge(@key => @result))
          )
        end

        @tracker.on_close if @close
        @tracker.on_error(@error) if @error
      end

      def check_ready_and_track(tracker)
        depend_value = ->(v) { @result = v }
        depend_error = ->(e) { flush(e) }
        depend_close = -> { flush }

        if @subscription.nil?
          @tracker = tracker
          @subscription = @trackable.on(
            value: depend_value, error: depend_error, close: depend_close
          )
        end
      end

      def call(tracker)
        value = ->(v) do
          if @result.nil?
            @lock.synchronize do
              buffer << v

              check_ready_and_track(tracker)
            end
          else
            tracker.on_value(
              OpenStruct.new({ value: v }.merge(@key => @result))
            )
          end
        end

        error = ->(e) do
          if @result.nil?
            @lock.synchronize do
              @error = e

              check_ready_and_track(tracker)
            end
          else
            tracker.on_error(e)
          end
        end

        close = -> do
          if @result.nil?
            @lock.synchronize do
              @close = true

              check_ready_and_track(tracker)
            end
          else
            tracker.on_close
          end
        end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: value,
          error: error,
          close: close
        )
      end
    end
  end
end
