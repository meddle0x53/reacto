require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class RescueAndReplaceError
      def initialize(action)
        @action = action
      end

      def call(tracker)
        error = -> (e) do
          trackable = @action.call(e)

          trackable.send(:do_track, tracker)
        end

        Subscriptions::OperationSubscription.new(tracker, error: error)
      end
    end
  end
end
