require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Merge
      def initialize(trackable)
        @trackable = trackable
        @close_notifications = 2
      end

      def call(tracker)
        @trackable.send(:do_track, tracker)
        close = lambda do
          @close_notifications -= 1
          tracker.on_close if @close_notifications == 0
        end
        Subscriptions::OperationSubscription.new(
          tracker,
          close: close
        )
      end
    end
  end
end

