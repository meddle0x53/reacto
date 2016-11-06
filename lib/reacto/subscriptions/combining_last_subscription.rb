require 'reacto/constants'
require 'reacto/subscriptions/composite_subscription'

module Reacto
  module Subscriptions
    class CombiningLastSubscription < CompositeSubscription
      def subscribed?
        @subscriptions.all?(&:subscribed?)
      end

      def after_on_value(_)
        return if @subscriptions.map(&:last_value).any? { |vl| vl == NO_VALUE }
        @subscriptions.each { |sub| sub.last_value = NO_VALUE }
      end

      def on_close
        return unless subscribed?
        @subscriber.on_close
      end
    end
  end
end
