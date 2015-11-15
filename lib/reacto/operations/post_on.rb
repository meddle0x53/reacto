require 'reacto/subscriptions/executor_subscription'

module Reacto
  module Operations
    class PostOn
      def initialize(executor)
        @executor = executor
      end

      def call(tracker)
        Subscriptions::ExecutorSubscription.new(
          tracker, @executor
        )
      end
    end
  end
end

