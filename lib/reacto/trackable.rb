require 'concurrent/executor/immediate_executor'

require 'reacto/subscriptions'
require 'reacto/tracker'

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
  end
end
