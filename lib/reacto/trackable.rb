require 'concurrent/executor/immediate_executor'

require 'reacto/subscriptions'
require 'reacto/tracker'
require 'reacto/operations'

module Reacto
  class Trackable
    TOPICS = [:open, :value, :error, :close]

    def initialize(action = NO_ACTION, &block)
      @action = block_given? ? block : action
      @executor = Concurrent::ImmediateExecutor.new
    end

    def on(trackers = {})
      unless (trackers.keys - TOPICS).empty?
        raise "This Trackable supports only #{TOPICS}, but #{trackers.keys} were passed."
      end

      track(Tracker.new(trackers))
    end

    def off(notification_tracker)
      # Clean-up logic
    end

    def track(notification_tracker)
      subscription = Subscriptions::TrackerSubscription.new(notification_tracker, self)

      @executor.post(subscription, &@action)

      Subscriptions::SubscriptionWrapper.new(subscription)
    end

    def lift(operation = nil, &block)
      operation = block_given? ? block : operation
      Trackable.new do |tracker_subscription|
        begin
          lift_behaviour(operation.call(tracker_subscription))
        rescue Exception => e
          tracker_subscription.on_error(e)
        end
      end
    end

    def map(mapping = nil, &block)
      lift(Operations::Map.new(block_given? ? block : mapping))
    end

    private

    def lift_behaviour(lifted_tracker_subscription)
      begin
        lifted_tracker_subscription.on_open
        @action.call(lifted_tracker_subscription)
      rescue Exception => e
        lifted_tracker_subscription.on_error(e)
      end
    end
  end
end
