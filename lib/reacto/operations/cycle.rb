require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Cycle
      def initialize(behaviour, n = nil)
        @behaviour = behaviour
        @n = n
      end

      def call(tracker)

        close = -> do
          if @n.nil? || @n > 1
            next_n = @n.nil? ? @n : @n - 1
            @behaviour.call(self.class.new(@behaviour, next_n).call(tracker))
          else
            tracker.on_close
          end
        end

        Subscriptions::OperationSubscription.new(tracker, close: close)
      end
    end
  end
end

