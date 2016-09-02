require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Retry
      def initialize(behaviour, retries = 1)
        @behaviour = behaviour
        @retries = retries
      end

      def call(tracker)
        error = ->(e) do
          @retries -= 1

          if @retries < 0
            tracker.on_error(e)
          else
            @behaviour.call(call(tracker))
          end
        end

        Subscriptions::OperationSubscription.new(tracker, error: error)
      end
    end
  end
end
