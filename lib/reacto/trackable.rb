module Reacto
  class Trackable

    TOPICS = [:open, :value, :error, :close]

    def initialize(action)
      @action = action
    end

    def on(trackers)
      unless (trackers.keys - TOPICS).empty?
        raise "This Trackable supports only #{TOPICS}, but #{trackers.keys} were passed."
      end

      track(NotificationTracker.new(trackers))
    end

    def off(notification_tracker)
      @trackers.delete(notification_tracker)
    end

    def track(notification_tracker)
      @trackers << notification_tracker
    end
  end

  NO_ACTION = -> (**args) {}

  class NotificationTracker
    attr_reader :on_open, :on_value, :on_error, :on_close

    DEFAULT_ON_ERROR = -> (e) { raise e }

    def initialize(
      open: NO_ACTION,
      value: NO_ACTION,
      error: DEFAULT_ON_ERROR,
      close: NO_ACTION
    )
      @on_open = open
      @on_value = value
      @on_error = error
      @on_close = close
    end
  end

  class Subscription
    attr_reader :notification_tracker, :trackable

    def initialize(notification_tracker, trackable)
      @notification_tracker = notification_tracker
      @trackable = trackable
    end

    def subscribed?
      !trackable.nil? && trackable.subscribed?(notification_tracker)
    end

    def unsubscribe
      @trackable.off(notification_tracker)

      @trackable = nil
      @notification_tracker = nil
    end
  end

end
