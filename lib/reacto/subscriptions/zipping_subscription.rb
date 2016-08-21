require 'reacto/constants'
require 'reacto/subscriptions/composite_subscription'
require 'reacto/subscriptions/buffered_subscription'

module Reacto
  module Subscriptions
    class ZippingSubscription < CompositeSubscription
      def current_value
        @current_value ||= 0
      end

      def subscribed?
        @subscriptions.all? { |s| s.subscribed? }
      end

      def waiting?
        @subscriptions.any? { |sub| sub.buffer[current_value] == NO_VALUE }
      end

      def on_value_subscriptions(_)
        @subscriber.on_value(
          @combinator.call(
            *@subscriptions.map { |sub| sub.buffer[current_value] }
          )
        )
        @current_value += 1
      end

      def on_close
        return unless subscribed?
        @subscriber.on_close
      end

      def subscription!
        subscription = BufferedSubscription.new(self)
        @subscriptions << subscription

        subscription
      end
    end
  end
end
