require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Map
      def initialize(mapping)
        @mapping = mapping
      end

      def call(tracker)
        Subscriptions::OperationSubscription.new(
          tracker,
          value: -> (v) { tracker.on_value(@mapping.call(v)) }
        )
      end
    end
  end
end
