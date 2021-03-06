require 'concurrent'
require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Merge
      def initialize(trackables, delay_error: false)
        @trackables = trackables

        @close_notifications =
          Concurrent::AtomicFixnum.new(@trackables.size + 1)
        @lock = Mutex.new
        @delay_error = delay_error
      end

      def call(tracker)
        error = nil

        close = -> () do
          @lock.synchronize do
            if @close_notifications.decrement == 0
              error.nil? ? tracker.on_close : tracker.on_error(error)
            end
          end
        end

        err =
          if @delay_error
            -> (er) do
              @lock.synchronize do
                error = er
                tracker.on_error(error) if @close_notifications.decrement == 0
              end
            end
          else
            tracker.method(:on_error)
          end

        sub = Subscriptions::OperationSubscription.new(
          tracker, close: close, error: err
        )

        @trackables.each { |trackable| trackable.send(:do_track, sub) }
        sub
      end
    end
  end
end
