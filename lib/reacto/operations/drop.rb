require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Drop

      def initialize(how_many_to_drop, offset = NO_VALUE)
        if how_many_to_drop < 0
          raise ArgumentError.new('Attempt to drop negative size!')
        end

        @how_many_to_drop = how_many_to_drop
        @dropped = 0
        @offset = offset
      end

      def call(tracker)
        behaviour = lambda do |value|
          @dropped += 1

          if @dropped > @how_many_to_drop
            if @offset != NO_VALUE
              if @offset <= 0
                tracker.on_close
                return
              else
                @offset -= 1
              end
            end
            tracker.on_value(value)
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
