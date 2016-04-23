require 'ostruct'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Wrap
      def initialize(args)
        if args.key?(:value)
          fail ArgumentError, "'value' is not valid key in the wrapping object"
        end

        if args.key?(:error)
          fail ArgumentError, "'error' is not valid key in the wrapping object"
        end

        @args = args
      end

      def call(tracker)
        value = ->(v) do
          data = @args.each_with_object({}) do |(key, val), obj|
            obj[key] = (val.respond_to? :call) ? val.call(v) : val
          end

          tracker.on_value OpenStruct.new({ value: v }.merge(data))
        end

        Subscriptions::OperationSubscription.new(
          tracker, value: value
        )
      end
    end
  end
end
