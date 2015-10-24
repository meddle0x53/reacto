module Reacto
  class Stream # Trackable?

    TOPICS = [:open, :value, :error, :close]

    def on(trackers)
      unless (trackers.keys - TOPICS).empty?
        raise "This Trackable supports only #{TOPICS}, but #{trackers.keys} were passed."
      end

      track(NotificationTracker.new(trackers))
    end

    def track(notification_tracker)
      @trackers << notification_tracker
    end

    private
    def listeners(type = :value)
      @listeners ||= {}
      @listeners[type] ||= []

      @listeners[type]
    end

    def notify(type = :value)
      listeners(type).each(&:call)
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
    attr_reader :notification_tracker, :trackable, :type

    def initialize(notification_tracker, trackable, type)
      @notification_tracker = notification_tracker
      @trackable = trackable
      @type = type
    end

    def subscribed?
      !trackable.nil? && trackable.subscribed?(notification_tracker, type)
    end

    def unsubscribe
      @trackable.off(notification_tracker)

      @trackable = nil
      @notification_tracker = nil
      @type = nil
    end
  end

end
