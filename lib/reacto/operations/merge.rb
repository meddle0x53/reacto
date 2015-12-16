require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Merge
      def initialize(trackable, delay_error: false)
        @trackable = trackable
        @close_notifications = 2
        @lock = Mutex.new
        @delay_error = delay_error
      end

      def call(tracker)
        close = lambda do
          @lock.synchronize do
            @close_notifications -= 1
            if @close_notifications == 0
              @error.nil? ? tracker.on_close : tracker.on_error(@error)
            end
          end
        end
        error =
          if @delay_error
            lambda do |e|
              @lock.synchronize do
                @error = e
                @close_notifications -= 1
                tracker.on_error(@error) if @close_notifications == 0
              end
            end
          else
            tracker.method(:on_error)
          end

        sub = Subscriptions::OperationSubscription.new(
          tracker,
          close: close,
          error: error
        )

        @trackable.send(:do_track, sub)
        sub
      end
    end
  end
end

