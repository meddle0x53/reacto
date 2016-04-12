require 'reacto/constants'
require 'reacto/subscriptions/operation_subscription'
require 'reacto/cache/memory'

module Reacto
  module Operations
    class Cache
      TYPES = {
        memory: Reacto::Cache::Memory
      }

      def initialize(type: :memory, settings: {})
        type = TYPES[type] if TYPES.key?(type)

        @cache = type.new(settings)
      end

      def call(tracker)
        if @cache.ready?
          @cache.each do |value|
            tracker.on_value(value)
          end

          if @cache.error?
            tracker.on_error(@cache.error)
          else
            tracker.on_close
          end

          NOTHING
        else
          Subscriptions::OperationSubscription.new(
            tracker,
            value: -> (v) do
              @cache.on_value(v)
              tracker.on_value(v)
            end,
            error: -> (e) do
              @cache.on_error(e)
              tracker.on_error(e)
            end,
            close: -> () do
              @cache.on_close
              tracker.on_close
            end
          )
        end
      end
    end
  end
end
