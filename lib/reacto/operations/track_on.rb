require 'reacto/subscriptions/executor_subscription'

module Reacto
  module Operations
    class TrackOn
      def initialize(executor)
        @executor = executor
      end

      def call(tracker)
        Subscriptions::ExecutorSubscription.new(tracker, @executor)
      end
    end
  end
end
