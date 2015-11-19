require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Take

      def initialize(how_many_to_take)
        if how_many_to_take < 0
          raise ArgumentError.new('Attempt to take negative size!')
        end

        @how_many_to_take = how_many_to_take
        @taken = 0
      end

      def call(tracker)
        behaviour = lambda do |value|
          if @taken < @how_many_to_take
            tracker.on_value(value)
            @taken += 1
          else
            tracker.on_close
            unsubscribe
          end
        end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: behaviour
        )
      end
    end
  end
end



