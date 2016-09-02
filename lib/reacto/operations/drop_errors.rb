require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class DropErrors
      def call(tracker)
        Subscriptions::OperationSubscription.new(
          tracker,
          error: ->(e) {}
        )
      end
    end
  end
end
