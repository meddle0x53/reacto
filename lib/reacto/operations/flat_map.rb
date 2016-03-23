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

        Subscriptions::OperationSubscription.new(
          tracker, value: value
        )
      end
    end
  end
end

