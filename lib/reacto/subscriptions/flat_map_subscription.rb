require 'reacto/constants'
require 'reacto/subscriptions/composite_subscription'

module Reacto
  module Subscriptions
    class FlatMapSubscription < CompositeSubscription
      attr_accessor :source_closed

      def initialize(subscriber)
        super(nil, subscriber)

        @source_closed = false
      end

      def waiting?
        false
      end

      def on_value_subscriptions(v)
        @subscriber.on_value(v)
      end

      def on_close
        return unless source_closed
        return unless subscribed?
        return unless @subscriptions.all?(&:closed?)

        @subscriber.on_close
        unsubscribe
      end
    end
  end
end
