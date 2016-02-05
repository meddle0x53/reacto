require 'concurrent'

require 'reacto/behaviours'
require 'reacto/subscriptions'
require 'reacto/tracker'
require 'reacto/operations'
require 'reacto/executors'
require 'reacto/resources'

module Reacto
  class Trackable
    TOPICS = [:open, :value, :error, :close]

    class << self
      def never
        self.new
      end

      def combine(*trackables, &block)
        make do |subscriber|
          main =
            Subscriptions::CombiningSubscription.new(block, subscriber)
          trackables.each do |trackable|
            trackable.do_track main.subscription!
          end
        end
      end

      def zip(*trackables, &block)
        make do |subscriber|
          main = Subscriptions::ZippingSubscription.new(block, subscriber)
          trackables.each do |trackable|
            trackable.do_track main.subscription!
          end
        end
      end

      def close(executor = nil)
        make(nil, executor) do |subscriber|
          subscriber.on_close
        end
      end

      def error(err, executor = nil)
        make(nil, executor) do |subscriber|
          subscriber.on_error(err)
        end
      end

      def make(behaviour = NO_ACTION, executor = nil, &block)
        behaviour = block_given? ? block : behaviour
        self.new(behaviour, executor)
      end

      def later(secs, value, executor: Reacto::Executors.tasks)
        if executor.is_a?(Concurrent::ImmediateExecutor)
          make do |tracker|
            sleep secs
            Behaviours.single_tracker_value(tracker, value)
          end
        else
          make do |tracker|
            Concurrent::ScheduledTask.execute(secs, executor: executor) do
              Behaviours.single_tracker_value(tracker, value)
            end
          end
        end
      end

      def interval(
        interval,
        enumerator = Behaviours.integers_enumerator,
        executor: nil
      )
        if executor.is_a?(Concurrent::ImmediateExecutor)
          make do |tracker|
            Behaviours.with_close_and_error(tracker) do |subscriber|
              while subscriber.subscribed?
                sleep interval if subscriber.subscribed?
                if subscriber.subscribed?
                  begin
                    subscriber.on_value(enumerator.next)
                  rescue StopIteration
                    break
                  end
                else
                  break
                end
              end
            end
          end
        else
          make do |tracker|
            queue = Queue.new
            task = Concurrent::TimerTask.new(execution_interval: interval) do
              queue.push('ready')
            end
            thread = Thread.new do
              begin
                loop do
                  queue.pop
                  break unless tracker.subscribed?

                  begin
                    value = enumerator.next
                    tracker.on_value(value)
                  rescue StopIteration
                    tracker.on_close if tracker.subscribed?
                    break
                  rescue StandardError => error
                    tracker.on_error(error) if tracker.subscribed?
                    break
                  end
                end
              ensure
                task.shutdown
              end
            end
            task.execute

            tracker.add_resource(Reacto::Resources::ExecutorResource.new(
              task, threads: [thread]
            ))
          end
        end
      end

      def value(value, executor = nil)
        make(Behaviours.single_value(value), executor)
      end

      def enumerable(enumerable, executor = nil)
        make(nil, executor) do |tracker|
          begin
            enumerable.each do |val|
              break unless tracker.subscribed?
              tracker.on_value(val)
            end

            tracker.on_close if tracker.subscribed?
          rescue => error
            tracker.on_error(error) if tracker.subscribed?
          end
        end
      end

      def combine_with(function, *trackables)
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

    def map(mapping = nil, error: nil, close: nil, &block)
      lift(Operations::Map.new(
        block_given? ? block : mapping, error: error, close: close
      ))
    end

    def select(filter = nil, &block)
      lift(Operations::Select.new(block_given? ? block : filter))
    end

    def inject(initial = NO_VALUE, injector = nil, &block)
      lift(Operations::Inject.new(block_given? ? block : injector, initial))
    end

    def diff(initial = NO_VALUE, fn = Operations::Diff::DEFAULT_FN, &block)
      lift(Operations::Diff.new(block_given? ? block : fn, initial))
    end

    def drop(how_many_to_drop)
      lift(Operations::Drop.new(how_many_to_drop))
    end

    def take(how_many_to_take)
      lift(Operations::Take.new(how_many_to_take))
    end

    def uniq
      lift(Operations::Uniq.new)
    end

    def flatten
      lift(Operations::Flatten.new)
    end

    def last
      lift(Operations::Last.new)
    end

    def prepend(enumerable)
      lift(Operations::Prepend.new(enumerable))
    end

    def concat(trackable)
      lift(Operations::Concat.new(trackable))
    end

    def merge(trackable, delay_error: false)
      lift(Operations::Merge.new(trackable, delay_error: delay_error))
    end

    def buffer(count: nil, delay: nil)
      lift(Operations::Buffer.new(count: count, delay: delay))
    end

    def track_on(executor)
      lift(Operations::TrackOn.new(executor))
    end

    def execute_on(executor)
      Trackable.new(@behaviour, executor)
    end

    def await(subscription, timeout = nil)
      latch = Concurrent::CountDownLatch.new(1)
      subscription.add(Subscriptions.on_close_and_error { latch.count_down })
      latch.wait(timeout)
    end

    alias_method :skip, :drop

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
