require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Map
      def initialize(mapping, error: nil)
        @mapping = mapping
        @error = error
      end

      def call(tracker)
        error = if @error
                  -> (e) { tracker.on_error(@error.call(e)) }
                else
                  tracker.method(:on_error)
                end
        Subscriptions::OperationSubscription.new(
          tracker,
          value: -> (v) { tracker.on_value(@mapping.call(v)) },
          error: error
        )
      end
    end
  end
end
