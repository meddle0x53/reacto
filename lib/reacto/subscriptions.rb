require 'reacto/subscriptions/subscription'
require 'reacto/subscriptions/subscription_wrapper'
require 'reacto/subscriptions/tracker_subscription'
require 'reacto/subscriptions/operation_subscription'
require 'reacto/subscriptions/executor_subscription'
require 'reacto/subscriptions/simple_subscription'
require 'reacto/subscriptions/combining_subscription'

module Reacto
  module Subscriptions
    class << self
      def on_close(&block)
        SimpleSubscription.new(close: block)
      end

      def on_close_and_error(&block)
        SimpleSubscription.new(
          close: -> () { block.call },
          error: -> (_e) { block.call }
        )
      end
    end
  end
end
