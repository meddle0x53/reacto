require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Map
      def initialize(mapping, error: nil, close: nil)
        @mapping = mapping
        @error = error
        @close = close
      end

      def call(tracker)
        error =
          if @error
            -> (e) { tracker.on_error(@error.call(e)) }
          else
            tracker.method(:on_error)
          end

        close =
          if @close
            -> () do
              tracker.on_value(@close.call)
              tracker.on_close
            end
          else
            tracker.method(:on_close)
          end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: -> (v) { tracker.on_value(@mapping.call(v)) },
          error: error,
          close: close
        )
      end
    end
  end
end
