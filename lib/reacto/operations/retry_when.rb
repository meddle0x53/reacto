require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class RetryWhen
      def initialize(behaviour, predicate)
        @behaviour = behaviour
        @predicate = predicate
        @retries = {}
      end

      def call(tracker)
        @retries[tracker] ||= 0

        error = -> (e) do
          should_retry = @predicate.call(e, @retries[tracker])

          if should_retry
            @retries[tracker] += 1
            @behaviour.call(call(tracker))
          else
            tracker.on_error(e)
          end
        end

        Subscriptions::OperationSubscription.new(tracker, error: error)
      end
    end
  end
end
