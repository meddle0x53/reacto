require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class EachWithObject
      def initialize(action, obj)
        @action = action
        @obj = obj
      end

      def call(tracker)
        memo = @obj

        close = -> () do
          tracker.on_value(memo)
          tracker.on_close
        end

        error = -> (e) do
          tracker.on_value(memo)
          tracker.on_error(e)
        end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: -> (v) { @action.call(v, memo) }, error: error, close: close
        )
      end
    end
  end
end
