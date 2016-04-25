require 'reacto/subscriptions/operation_subscription'
require 'reacto/subscriptions/flat_map_subscription'

module Reacto
  module Operations
    class FlatMap
      def initialize(transform)
        @transform = transform
      end

      def call(tracker)
        subscription = Subscriptions::FlatMapSubscription.new(tracker)
        value = lambda do |v|
          trackable = @transform.call(v)

          trackable.do_track subscription.subscription!
        end

        close = lambda do
          subscription.source_closed = true
          return unless subscription.closed?

          tracker.on_close
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value, close: close
        )
      end
    end
  end
end

