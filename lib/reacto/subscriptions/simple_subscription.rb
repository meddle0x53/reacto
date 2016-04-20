require 'reacto/constants'
require 'reacto/subscriptions/subscription'

module Reacto
  module Subscriptions
    class SimpleSubscription
      include Subscription

      def initialize(
        open: NO_ACTION,
        value: NO_ACTION,
        error: DEFAULT_ON_ERROR,
        close: NO_ACTION
      )
        @open = open
        @value = value
        @error = error
        @close = close

        @subscribed = true
        @subscriptions = []
        @resources = []
      end

      def subscribed?
        @subscribed
      end

      def unsubscribe
        @subscriptions.each(&:unsubscribe)
        @subscribed = false
        @resources.each(&:cleanup)
        @resources = []
      end

      def add(subscription)
        return unless subscribed?

        @subscriptions << subscription
      end

      def add_resource(resource)
        return unless subscribed?

        @resources << resource
      end

      def on_open
        return unless subscribed?

        @open.call
        @subscriptions.each(&:on_open)
      end

      def on_value(v)
        return unless subscribed?

        @value.call(v)
        @subscriptions.each { |s| s.on_value(v) }
      end

      def on_error(e)
        return unless subscribed?

        @error.call(e)
        @subscriptions.each { |s| s.on_error(e) }
        unsubscribe
      end

      def on_close
        return unless subscribed?

        @close.call
        @subscriptions.each(&:on_close)
        unsubscribe
      end
    end
  end
end

