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

        inject = lambda do |v|
          if @current == NO_VALUE
            @current = v
          else
            @current = @injector.call(@current, v)
          end

          @has_values = true
          tracker.on_value(@current)
        end

        close = lambda do
          unless @has_values || @current == NO_VALUE
            tracker.on_value(@current)
          end

          tracker.on_close
        end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: inject,
          close: close
        )
      end
    end
  end
end
