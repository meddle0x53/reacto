require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Take
      def initialize(how_many_to_take)
        if how_many_to_take < 0
          raise ArgumentError.new('Attempt to take negative size!')
        end

        @how_many_to_take = how_many_to_take
      end

      def call(tracker)
        taken = 0
        closed = false

        behaviour = -> (value) do
          return if closed
          if taken < @how_many_to_take
            tracker.on_value(value)
            taken += 1
          else
            closed = true
            tracker.on_close
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



