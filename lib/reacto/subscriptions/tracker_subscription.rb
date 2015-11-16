require 'reacto/subscriptions/subscription'

module Reacto
  module Subscriptions
    class TrackerSubscription
      extend Forwardable
      include Subscription

      delegate(
        [:on_open, :on_value, :on_error, :on_close] => :@notification_tracker
      )

      def initialize(notification_tracker, trackable)
        @notification_tracker = notification_tracker
        @trackable = trackable

        @subscribed = true
      end

      def subscribed?
        @subscribed
      end

      def unsubscribe
        @trackable.off(@notification_tracker)

        @trackable = nil
        @notification_tracker = nil
        @subscribed = false
      end
    end
  end
end
