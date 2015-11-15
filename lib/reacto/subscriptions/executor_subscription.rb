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

        @executor.shutdown? || @executor.shuttingdown?
      end

      def unsubscribe
        @wrapped.unsubscribe

        @executor.post(@executor.method(:shutdown))
      end

      def on_open
        @executor.post(@wrapped.method(:on_open))
      end

      def on_value(value)
        return if !subscribed? || @closed

        @executor.post(value, @wrapped.method(:on_value))
      end

      def on_close
        return if !subscribed? || @closed

        @closed = true
        @executor.post(@wrapped.method(:on_close))
      end

      def on_error(error)
        return if !subscribed? || @closed

        unsubscribe
        @closed = true
        @executor.post(error, @wrapped.method(:on_error))
      end
    end
  end
end

