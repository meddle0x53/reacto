require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Drop

      def initialize(how_many_to_drop)
        if how_many_to_drop < 0
          raise ArgumentError.new('Attempt to drop negative size!')
        end

        @how_many_to_drop = how_many_to_drop
        @dropped = 0
      end

      def call(tracker)
        behaviour = lambda do |value|
          @dropped += 1
          tracker.on_value(value) if @dropped > @how_many_to_drop
        end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: behaviour
        )
      end
    end
  end
end
