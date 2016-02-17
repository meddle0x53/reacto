require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'
require 'reacto/executors'

module Reacto
  module Operations
    class Delay

      def initialize(timeout, executor = Concurrent::ImmediateExecutor)
        @timeout = timeout
        @executor = executor
      end

      def call(tracker)
        return tracker if @timeout <= 0

        # TODO
        Subscriptions::OperationSubscription.new(
          tracker
        )
      end
    end
  end
end

