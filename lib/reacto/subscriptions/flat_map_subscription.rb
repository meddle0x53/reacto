require 'reacto/constants'
require 'reacto/subscriptions/composite_subscription'

module Reacto
  module Subscriptions
    class FlatMapSubscription < CompositeSubscription
      def initialize(subscriber)
        super(nil, subscriber)
      end

      def waiting?
        false
      end

      def on_value_subscriptions(v)
        @subscriber.on_value(v)
      end

      def on_close
        return unless subscribed?
        return unless @subscriptions.any? { |s| !s.closed? }

        @subscriber.on_close
        unsubscribe
      end
    end
  end
end
