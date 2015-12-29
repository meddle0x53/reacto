require 'reacto/constants'
require 'reacto/subscriptions/subscription'

module Reacto
  module Subscriptions
    class CombiningSubscription
      include Subscription

      class InnerSubscription < SimpleSubscription
        include Subscription

        attr_reader :last_value, :last_error

        def initialize(parent)
          @parent = parent
          @closed = false
          @active = false
          @last_value = NO_VALUE
          @last_error = nil

          open = lambda do
            @active = true
            @parent.on_open
          end

          value = lambda do |v|
            @last_value = v
            @parent.on_value(v)
          end

          error = lambda do |e|
            @last_error = e
            @parent.on_error(e)
          end

          close = lambda do
            @closed = true
            @parent.on_close
          end

          super(open: open, value: value, error: error, close: close)
        end

        def active?
          @active
        end

        def closed?
          @closed
        end
      end

      def initialize(combinator, subscriber)
        @combinator = combinator
        @subscriptions = []
        @subscriber = subscriber
      end

      def subscribed?
        @subscriptions.any? { |s| s.subscribed? }
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

      def on_value(_)
        return unless subscribed?
        @subscriber.on_value(
          @combinator.call(*@subscriptions.map(&:last_value))
        )
      end

      def on_error(e)
        # Introduce a multi-error and not call on_error right away when there is
        # an error and an option is set?
        return unless subscribed?
        @subscriber.on_error(e)
      end

      def on_close
        return unless subscribed?
        return unless @subscriptions.any? { |s| !s.closed? }

        @subscriber.on_close
      end

      def subscription!
        subscription = InnerSubscription.new(self)
        @subscriptions << subscription

        subscription
      end
    end
  end
end
