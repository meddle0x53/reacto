require 'reacto/subscriptions'
require 'reacto/tracker'
require 'reacto/operations'
require 'reacto/executors'

module Reacto
  class Trackable
    TOPICS = [:open, :value, :error, :close]

    class << self
      def never
        self.new
      end

      def make(behaviour = NO_ACTION, &block)
        behaviour = block_given? ? block : behaviour
        self.new(behaviour)
      end

      def timeout(secs_to_wait, value)
        self.new(nil, Reacto::Executors.tasks) do |tracker|
          sleep secs_to_wait

          tracker.on_value(value)
          tracker.on_close
        end
      end
    end

    def initialize(behaviour = NO_ACTION, executor = nil, &block)
      @behaviour = block_given? ? block : behaviour
      @executor = executor
    end

    def on(trackers = {})
      unless (trackers.keys - TOPICS).empty?
        raise "This Trackable supports only #{TOPICS}, " \
          "but #{trackers.keys} were passed."
      end

      track(Tracker.new(trackers))
    end

    def off(notification_tracker)
      # Clean-up logic
    end

    def track(notification_tracker)
      subscription =
        Subscriptions::TrackerSubscription.new(notification_tracker, self)

      do_track(subscription)

      Subscriptions::SubscriptionWrapper.new(subscription)
    end

    def lift(operation = nil, &block)
      operation = block_given? ? block : operation
      Trackable.new(nil, @executor) do |tracker_subscription|
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

    def select(filter = nil, &block)
      lift(Operations::Select.new(block_given? ? block : filter))
    end

    def inject(initial = Operations::Inject::NO_INITIAL, injector = nil, &block)
      lift(Operations::Inject.new(block_given? ? block : injector, initial))
    end

    def drop(how_many_to_drop)
      lift(Operations::Drop.new(how_many_to_drop))
    end

    def take(how_many_to_take)
      lift(Operations::Take.new(how_many_to_take))
    end

    def track_on(executor)
      lift(Operations::TrackOn.new(executor))
    end

    def execute_on(executor)
      Trackable.new(@behaviour, executor)
    end

      def await(timeout = nil, subscription)
      # latch here...
      #subscription.add()
    end

    protected

    def do_track(subscription)
      if @executor
        @executor.post(subscription, &@behaviour)
      else
        @behaviour.call(subscription)
      end
    end

    private

    def lift_behaviour(lifted_tracker_subscription)
      begin
        lifted_tracker_subscription.on_open
        @behaviour.call(lifted_tracker_subscription)
      rescue Exception => e
        lifted_tracker_subscription.on_error(e)
      end
    end
  end
end
