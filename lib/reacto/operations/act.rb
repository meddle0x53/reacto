require 'ostruct'

require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Act
      ALL = %i(value error close)


      def initialize(action = NO_ACTION, on = ALL)
        @action = action
        @on = on

        @on = ALL if @on == :all
      end

      def call(tracker)
        value =
          if @on.include?(:value)
            value_action(tracker)
          else
            tracker.method(:on_value)
          end

        error =
          if @on.include?(:error)
            error_action(tracker)
          else
            tracker.method(:on_error)
          end

        close =
          if @on.include?(:close)
            close_action(tracker)
          else
            tracker.method(:on_close)
          end

        Subscriptions::OperationSubscription.new(
          tracker, value: value, error: error, close: close
        )
      end

      def value_action(tracker)
        lambda do |value|
          @action.call(OpenStruct.new(value: value, type: :value))
          tracker.on_value(value)
        end
      end

      def error_action(tracker)
        lambda do |error|
          @action.call(OpenStruct.new(error: error, type: :error))
          tracker.on_error(error)
        end
      end

      def close_action(tracker)
        lambda do
          @action.call(OpenStruct.new(type: :close))
          tracker.on_close
        end
      end
    end
  end
end

