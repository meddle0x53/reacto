require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Diff
      DEFAULT_FN = -> (a, b) { [a, b] }

      def initialize(fn = DEFAULT_FN, initial = NO_VALUE)
        @fn = fn
        @prev = initial
      end

      def call(tracker)
        value = lambda do |v|
          if @prev == NO_VALUE
            @prev = v
            return
          end

          current = @fn.call(@prev, v)
          @prev = v

          tracker.on_value(current)
        end


        Subscriptions::OperationSubscription.new(
          tracker,
          value: value
        )
      end
    end
  end
end
