require 'reacto/subscriptions/subscription'

module Reacto
  module Subscriptions
    class SubscriptionWrapper
      extend Forwardable
      include Subscription

      delegate ['subscribed?', :unsubscribe] => :@wrapped

      def initialize(wrapped)
        @wrapped = wrapped
      end
    end
  end
end
