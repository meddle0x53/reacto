require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Diff

      def initialize(fn = -> (a, b) { [a, b] }, initial = NO_VALUE)
        @fn = fn
        @prev = initial
      end

      def call(tracker)
        value = lambda do |v|
          return if @prev == NO_VALUE
          current = @diff.call(@prev, v)

          @prev = v
          tracker.on_value(current)
        end


        Subscriptions::OperationSubscription.new(
          tracker,
          value: value,
        )
      end
    end
  end
end

