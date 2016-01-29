require 'reacto/constants'
require 'reacto/subscriptions/combining_subscription'

module Reacto
  module Subscriptions
    class ZippingSubscription < CombiningSubscription
      def on_value(v)
        super(v)

        @subscriptions.each { |sub| sub.last_value = NO_VALUE }
      end

      def on_close
        return unless subscribed?

        @subscriber.on_close
      end
    end
  end
end
