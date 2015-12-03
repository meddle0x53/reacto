require 'reacto/subscriptions/subscription'

module Reacto
  module Subscriptions
    class TrackerSubscription
      include Subscription

      def initialize(notification_tracker, trackable)
        @notification_tracker = notification_tracker
        @trackable = trackable

        @subscribed = true
        @subscriptions = []
      end

      def subscribed?
        @subscribed
      end

      def unsubscribe
        @subscriptions.each(&:unsubscribe)

        @trackable.off(@notification_tracker)

        @trackable = nil
        @notification_tracker = nil
        @subscribed = false
      end

      def add(subscription)
        return unless subscribed?

        @subscriptions << subscription
      end

      def on_open
        return unless subscribed?

        @notification_tracker.on_open
        @subscriptions.each(&:on_open)
      end

      def on_value(v)
        return unless subscribed?

        @notification_tracker.on_value(v)
        @subscriptions.each { |s| s.on_value(v) }
      end

      def on_error(e)
        return unless subscribed?

        @notification_tracker.on_error(e)
        @subscriptions.each { |s| s.on_error(e) }
        unsubscribe
      end

      def on_close
        return unless subscribed?

        @notification_tracker.on_close
        @subscriptions.each(&:on_close)
        unsubscribe
      end
    end
  end
end
