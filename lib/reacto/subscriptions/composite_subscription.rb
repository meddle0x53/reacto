require 'reacto/constants'
require 'reacto/subscriptions/subscription'
require 'reacto/subscriptions/inner_subscription'

module Reacto
  module Subscriptions
    class CompositeSubscription
      include Subscription

      def initialize(combinator, subscriber)
        @combinator = combinator
        @subscriptions = []
        @subscriber = subscriber
      end

      def subscribed?
        @subscriptions.any?(&:subscribed?)
      end

      def unsubscribe
        @subscriptions.each(&:unsubscribe)
        @subscriptions = []
      end

      def add(_)
      end

      def add_resource(_)
      end

      def on_open
        return unless subscribed?
        return unless @subscriptions.any? { |s| !s.active? }
        @subscriber.on_open
      end

      def waiting?
        @subscriptions.map(&:last_value).any? { |v| v == NO_VALUE }
      end

      def on_value(val)
        return unless subscribed?
        return if waiting?

        on_value_subscriptions(val)
        after_on_value(val)
      end

      def on_value_subscriptions(_)
        @subscriber.on_value(
          @combinator.call(*@subscriptions.map(&:last_value))
        )
      end

      def after_on_value(_)
        # nothing by default
      end

      def on_error(e)
        # Introduce a multi-error and not call on_error right away when there is
        # an error and an option is set?
        return unless subscribed?
        @subscriber.on_error(e)
      end

      def closed?
        @subscriptions.all?(&:closed?)
      end

      def on_close
        return unless subscribed?
        return if @subscriptions.any? { |s| !s.closed? }

        @subscriber.on_close
        unsubscribe
      end

      def subscription!
        subscription = InnerSubscription.new(self)
        @subscriptions << subscription

        subscription
      end
    end
  end
end
