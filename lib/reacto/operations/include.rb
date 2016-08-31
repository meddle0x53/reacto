require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Include
      def initialize(value)
        @value = value
      end

      def call(tracker)
        includes = false

        behaviour = -> (val) do
          if @value == val
            includes = true

            tracker.on_value(includes)
            tracker.on_close
          end
        end

        close = -> () do
          tracker.on_value(includes) unless includes
          tracker.on_close
        end

        error = -> (e) do
          tracker.on_value(includes) unless includes
          tracker.on_error(e)
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: behaviour, error: error, close: close
        )
      end
    end
  end
end
