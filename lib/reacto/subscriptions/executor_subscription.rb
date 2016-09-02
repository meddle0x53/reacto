require 'reacto/subscriptions/subscription'
require 'reacto/tracker'

module Reacto
  module Subscriptions
    class ExecutorSubscription
      include Subscription

      def initialize(subscription, executor)
        @executor = executor
        @wrapped = subscription
        @closed = false
      end

      def subscribed?
        unsubscribe unless @wrapped.subscribed?

        @executor.running?
      end

      def unsubscribe
        @wrapped.unsubscribe

        @executor.post(&@executor.method(:shutdown))
      end

      def add(subscription)
        @wrapped.add(subscription)
      end

      def add_resource(resource)
        @wrapped.add_resource(resource)
      end

      def on_open
        @executor.post(&@wrapped.method(:on_open))
      end

      def on_value(v)
        return if !subscribed? || @closed

        @executor.post(v, &@wrapped.method(:on_value))
      end

      def on_close
        return if !subscribed? || @closed

        unsubscribe_subscription = Subscriptions.on_close_and_error do
          @executor.post(&method(:unsubscribe))
          @closed = true
        end
        @wrapped.add(unsubscribe_subscription)

        @executor.post(&@wrapped.method(:on_close))
      end

      def on_error(error)
        return if !subscribed? || @closed

        unsubscribe_subscription = Subscriptions.on_close_and_error do
          @executor.post(&method(:unsubscribe))
          @closed = true
        end
        @wrapped.add(unsubscribe_subscription)

        @executor.post(error, &@wrapped.method(:on_error))
      end
    end
  end
end
