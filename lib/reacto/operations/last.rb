require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Last
      def initialize
        @marker = {}
        @prev = @marker
      end

      def call(tracker)
        close = lambda do
          tracker.on_value(@prev) if @prev != @marker
          tracker.on_close
        end
        error = lambda do |e|
          tracker.on_value(@prev) if @prev != @marker
          tracker.on_error(e)
        end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: -> (v) { @prev = v },
          error: error,
          close: close
        )
      end
    end
  end
end
