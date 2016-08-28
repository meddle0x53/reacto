require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class EachCollect
      def initialize(
        n,
        reset_action: -> (_) { [] }, collect_action: nil,
        init_action: NO_ACTION, on_error: nil, on_close: nil
      )
        @n = n
        @reset_action = reset_action
        @collect_action = collect_action
        @init_action = init_action

        @error = on_error
        @close = on_close
      end

      def call(tracker)
        current = []
        @init_action.call

        unless @collect_action
          @collect_action = -> (value, collection) { collection << value }
        end

        error = @error ? @error : ->(e) do
          tracker.on_value(current) unless current.empty?
          tracker.on_error(e)
        end
        close = @close ? @close : ->() do
          tracker.on_value(current) unless current.empty?
          tracker.on_close
        end

        error = error == NO_ACTION ? tracker.method(:on_error) : error
        close = close == NO_ACTION ? tracker.method(:on_close) : close

        behaviour = -> (value) do
          @collect_action.call(value, current)

          if current.size == @n
            tracker.on_value(current)

            current = @reset_action.call(current)
          end
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: behaviour, error: error, close: close
        )
      end
    end
  end
end
