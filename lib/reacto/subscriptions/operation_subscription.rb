require 'reacto/subscriptions/subscription'
require 'reacto/tracker'

module Reacto
  module Subscriptions
    class OperationSubscription < Reacto::Tracker
      extend Forwardable
      include Subscription

      delegate ['subscribed?', :unsubscribe, :add, :add_resource] => :@wrapped

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
    end
  end
end
