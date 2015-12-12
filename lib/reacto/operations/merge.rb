require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Merge
      def initialize(trackable)
        @trackable = trackable
        @close_notifications = 2
        @lock = Mutex.new
      end

      def call(tracker)
        close = lambda do
          @lock.synchronize do
            @close_notifications -= 1
            tracker.on_close if @close_notifications == 0
          end
        end
        sub = Subscriptions::OperationSubscription.new(
          tracker,
          close: close
        )
        @trackable.send(:do_track, sub)
        sub
      end
    end
  end
end

