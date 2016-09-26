require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Inject
      def initialize(injector, initial = NO_VALUE)
        @injector = injector
        @initial = initial
      end

      def call(tracker)
        @current = @initial
        @has_values = false

        inject = -> (v) do
          @current = if @current == NO_VALUE
                       v
                     else
                       @injector.call(@current, v)
                     end

          @has_values = true
          tracker.on_value(@current)
        end

        close = -> () do
          unless @has_values || @current == NO_VALUE
            tracker.on_value(@current)
          end

          tracker.on_close
        end

        error = -> (e) do
          unless @has_values || @current == NO_VALUE
            tracker.on_value(@current)
          end

          tracker.on_error(e)
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: inject, close: close, error: error
        )
      end
    end
  end
end
