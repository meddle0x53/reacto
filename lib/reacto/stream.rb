module Reacto
  class Stream # Trackable?
    def on(listener, type: :value)
      listeners(type) << listener
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
