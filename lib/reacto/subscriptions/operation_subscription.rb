require 'reacto/subscriptions/subscription'
require 'reacto/tracker'

module Reacto
  module Subscriptions
    class OperationSubscription < Reacto::Tracker
      extend Forwardable
      include Subscription

      delegate ['subscribed?', :unsubscribe] => :@wrapped

      def initialize(
        subscription,
        open: subscription.method(:on_open),
        value: subscription.method(:on_value),
        error: subscription.method(:on_error),
        close: subscription.method(:on_close)
      )
        super(open: open, value: value, error: error, close: close)

        @wrapped = subscription
      end

      def open(&block)
        @open = block
        self
      end

      def value(&block)
        @value = block
        self
      end

      def error(&block)
        @error = block
        self
      end

      def close(&block)
        @close = block
        self
      end

    end
  end
end
