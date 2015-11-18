require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Inject

      NO_INITIAL = Object.new

      def initialize(injector, current = NO_INITIAL)
        @injector = injector
        @current = current
      end

      def call(tracker)
        inject = lambda do |v|
          if @current == NO_INITIAL
            @current = v
          else
            @current = @injector.call(@current, v)
          end

          tracker.on_value(@current)
        end

        Subscriptions::OperationSubscription.new(
          tracker,
          value: inject
        )
      end
    end
  end
end

