require 'concurrent/executor/immediate_executor'

module Reacto

  NO_ACTION = -> (*args) {}

  class NotificationTracker
    DEFAULT_ON_ERROR = -> (e) { raise e }

    def initialize(
      open: NO_ACTION,
      value: NO_ACTION,
      error: DEFAULT_ON_ERROR,
      close: NO_ACTION
    )
      @open = open
      @value = value
      @error = error
      @close = close
    end

    def on_open
      @open.call
    end

    def on_value(value)
      @value.call(value)
    end

    def on_error(error)
      @error.call(error)
    end

    def on_close
      @close.call
    end
  end

  module Subscription
    def subscribed?
      !@trackable.nil? && @trackable.subscribed?(@notification_tracker)
    end

    def unsubscribe
      @trackable.off(@notification_tracker)

      @trackable = nil
      @notification_tracker = nil
    end
  end

  class TrackerSubscription
    extend Forwardable
    include Subscription

    delegate [:on_open, :on_value, :on_error, :on_close] => :@notification_tracker

    def initialize(notification_tracker, trackable)
      @notification_tracker = notification_tracker
      @trackable = trackable
    end
  end

  class SubscriptionWrapper
    extend Forwardable
    include Subscription

    delegate ['subscribed?', :unsubscribe] => :@wrapped

    def initialize(wrapped)
      @wrapped = wrapped
    end
  end

  class Trackable

    TOPICS = [:open, :value, :error, :close]

    def initialize(action)
      @action = action
      @executor = Concurrent::ImmediateExecutor.new
    end

    def on(trackers = {})
      unless (trackers.keys - TOPICS).empty?
        raise "This Trackable supports only #{TOPICS}, but #{trackers.keys} were passed."
      end

      track(NotificationTracker.new(trackers))
    end

    def off(notification_tracker)
      # Clean-up logic
    end

    def track(notification_tracker)
      subscription = TrackerSubscription.new(notification_tracker, self)

      @executor.post(subscription, &@action)

      SubscriptionWrapper.new(subscription)
    end
  end
end
