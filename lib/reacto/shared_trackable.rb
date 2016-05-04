require 'reacto/trackable'

module Reacto
  class SharedTrackable < Trackable
    def initialize(
      behaviour = NO_ACTION,
      executor = nil,
      activate_on_subscribe = false,
      &block
    )

      super(behaviour, executor, &block)

      @activate_on_subscribe = activate_on_subscribe
      @active = false
    end

    def off(notification_tracker = nil)
      shared_subscription.subscriptions.reject! do |subscription|
        !subscription.subscribed?
      end

      return if shared_subscription.subscriptions.count > 0

      shared_subscription.unsubscribe
      @shared_subscription = nil
      @active = false
    end

    def track(notification_tracker)
      subscription =
        Subscriptions::TrackerSubscription.new(notification_tracker, self)

      shared_subscription.add(subscription)
      activate! if @activate_on_subscribe

      Subscriptions::SubscriptionWrapper.new(subscription)
    end

    def activate!
      return if @shared_subscription.nil?
      return if @active

      @active = true
      do_track(shared_subscription)

      self
    end

    def activate_on_subscribe
    end

    private

    def shared_subscription
      @shared_subscription ||= Subscriptions.shared_subscription(self)
    end
  end
end
