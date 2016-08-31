require 'concurrent'
require 'ostruct'

require 'reacto/constants'
require 'reacto/behaviours'
require 'reacto/subscriptions'
require 'reacto/tracker'
require 'reacto/operations'
require 'reacto/executors'
require 'reacto/resources'

module Reacto
  class Trackable
    include Enumerable

    TOPICS = %i(open value error close)

    EXECUTOR_ALIASES = {
      new_thread: Executors.new_thread,
      background: Executors.tasks,
      tasks: Executors.tasks,
      io: Executors.io,
      current: Executors.current,
      immediate: Executors.immediate,
      now: Executors.immediate
    }

    class << self
      def never
        self.new
      end

      def combine(*trackables, &block)
        combine_create(
          Subscriptions::CombiningSubscription, *trackables, &block
        )
      end

      def concat(*trackables)
        trackables.inject { |current, trackable| current.concat(trackable) }
      end

      def combine_last(*trackables, &block)
        combine_create(
          Subscriptions::CombiningLastSubscription, *trackables, &block
        )
      end

      def zip(*trackables, &block)
        combine_create(Subscriptions::ZippingSubscription, *trackables, &block)
      end

      def close(executor: nil)
        make(executor) { |subscriber| subscriber.on_close }
      end

      def error(err, executor: nil)
        make(executor) do |subscriber|
          subscriber.on_error(err)
        end
      end

      def make(executor_param = nil, executor: nil,  &block)
        real_executor = executor_param ? executor_param : executor

        behaviour = block_given? ? block : NO_ACTION
        self.new(real_executor, &behaviour)
      end

      def later(secs, value, executor: Reacto::Executors.tasks)
        stored = EXECUTOR_ALIASES[executor]
        executor = stored if stored

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
        stored = EXECUTOR_ALIASES[executor]
        executor = stored if stored

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
            Thread.abort_on_exception = true

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

      def repeat(array, int: 0.1, executor: nil)
        interval(
          int, Behaviours.array_repeat_enumerator(array), executor: executor
        )
      end

      def value(value, executor: nil)
        make(executor, &Behaviours.single_value(value))
      end

      def enumerable(enumerable, executor: nil)
        make(executor, &Behaviours.enumerable(enumerable))
      end

      alias_method :combine_latest, :combine

      private

      def combine_create(type, *trackables, &block)
        make do |subscriber|
          main = type.new(block, subscriber)
          trackables.each do |trackable|
            trackable.do_track main.subscription!
          end
        end
      end
    end

    def initialize(executor = nil, &block)
      @behaviour = block_given? ? block : NO_ACTION

      stored = EXECUTOR_ALIASES[executor]
      executor = stored if stored
      @executor = executor
    end

    def all?(&block)
      lift(Operations::BlockingEnumerable.new(:'all?', block))
    end

    def any?(&block)
      lift(Operations::BlockingEnumerable.new(:'any?', block))
    end

    def none?(&block)
      lift(Operations::BlockingEnumerable.new(:'none?', block))
    end

    def one?(&block)
      lift(Operations::BlockingEnumerable.new(:'one?', block))
    end

    def sort(&block)
      lift(Operations::BlockingEnumerable.new(:sort, block))
    end

    def sort_by(&block)
      return self unless block_given?

      lift(Operations::BlockingEnumerable.new(:sort_by, block))
    end

    def partition(executor: nil, &block)
      return self unless block_given?

      executor = retrieve_executor(executor)
      executor = @executor if executor.nil?

      lift(Operations::Partition.new(block, executor: executor))
    end

    def chunk(executor: nil, &block)
      return self unless block_given?

      executor = retrieve_executor(executor)
      executor = @executor if executor.nil?

      lift(Operations::Chunk.new(block, executor: executor))
    end

    def chunk_while(executor: nil, &block)
      executor = retrieve_executor(executor)
      executor = @executor if executor.nil?

      lift(Operations::ChunkWhile.new(block, executor: executor))
    end

    def cycle(n = nil)
      lift(Operations::Cycle.new(@behaviour, n))
    end

    def find(if_none = NO_VALUE, &block)
      trackable = select(&block).first

      if if_none != NO_VALUE
        trackable = trackable.append(if_none, condition: :source_empty)
      end

      trackable
    end

    def find_index(value = NO_VALUE, &block)
      predicate =
        if value != NO_VALUE
          -> (v) { value == v }
        else
          block
        end
      lift(Operations::FindIndex.new(predicate))
    end

    def count(value = NO_VALUE, &block)
      source =
        if value != NO_VALUE
          select(&Behaviours.same_predicate(value))
        elsif block_given?
          select(&block)
        else
          self
        end

      source.map(1).inject(&:+).last
    end

    def each_cons(n, &block)
      raise ArgumentError.new('invalid size') if n <= 0
      return each(&block) if n == 1

      reset_action = -> (current) { current[1..-1] }

      trackable = lift(Operations::EachCollect.new(
        n, reset_action: reset_action, on_error: NO_ACTION, on_close: NO_ACTION
      ))
      block_given? ? trackable.on(&block) : trackable
    end

    def each_slice(n, &block)
      raise ArgumentError.new('invalid size') if n <= 0

      trackable = lift(Operations::EachCollect.new(n))

      block_given? ? trackable.on(&block) : trackable
    end

    def each_with_index(&block)
      index = 0

      collect_action = -> (val, collection) do
        collection << val
        collection << index
        index += 1
      end

      trackable = lift(Operations::EachCollect.new(
        2, collect_action: collect_action, init_action: -> () { index = 0 },
        on_error: NO_ACTION, on_close: NO_ACTION
      ))

      block_given? ? trackable.on(&block) : trackable
    end

    def entries(n = nil)
      return [] if n && n.is_a?(Integer) && n <= 0

      trackable = self
      trackable = trackable.take(n) if n && n.is_a?(Integer) && n > 0

      result = []
      subscription = trackable.on(value: ->(v) { result << v })

      trackable.await(subscription)

      result
    end

    def to_a
      entries
    end

    def to_h
      to_a.to_h
    end

    def on(trackers = {}, &block)
      trackers[:value] = block if block_given?

      unless (trackers.keys - TOPICS).empty?
        raise "This Trackable supports only #{TOPICS}, " \
          "but #{trackers.keys} were passed."
      end

      track(Tracker.new(trackers))
    end

    def off(notification_tracker = nil)
      # Clean-up logic
    end

    def track(notification_tracker, &block)
      return on(&block) if block_given?

      subscription =
        Subscriptions::TrackerSubscription.new(notification_tracker, self)

      do_track(subscription)

      Subscriptions::SubscriptionWrapper.new(subscription)
    end

    def lift(operation = nil, &block)
      operation = block_given? ? block : operation
      create_lifted do |tracker_subscription|
        begin
          modified = operation.call(tracker_subscription)
          lift_behaviour(modified) unless modified == NOTHING
        rescue Exception => e
          tracker_subscription.on_error(e)
        end
      end
    end

    def flat_map(transform = nil, label: nil, &block)
      if label
        lift(Operations::OperationOnLabeled.new(
          label, block_given? ? block : transform, op: :flat_map
        ))
      else
        lift(Operations::FlatMap.new(block_given? ? block : transform))
      end
    end

    def flat_map_latest(transform = nil, &block)
      lift(Operations::FlatMapLatest.new(block_given? ? block : transform))
    end

    def map(val = NO_VALUE, error: nil, close: nil, label: nil, &block)
      action =
        if block_given?
          block
        else
          val == NO_VALUE ? IDENTITY_ACTION : Behaviours.constant(val)
        end
      if label
        lift(Operations::OperationOnLabeled.new(
          label, action, error: error, close: close
        ))
      else
        lift(Operations::Map.new(action, error: error, close: close))
      end
    end

    def max(&block)
      lift(Operations::Extremums.new(action: block))
    end

    def max_by(&block)
      lift(Operations::Extremums.new(by: block))
    end

    def min(&block)
      lift(Operations::Extremums.new(action: block, type: :min))
    end

    def min_by(&block)
      lift(Operations::Extremums.new(by: block, type: :min))
    end

    def minmax(&block)
      lift(Operations::Extremums.new(action: block, type: :minmax))
    end

    def minmax_by(&block)
      lift(Operations::Extremums.new(by: block, type: :minmax))
    end

    def grep(pattern, &block)
      select_map(-> (v) { pattern === v }, &block)
    end

    def grep_v(pattern, &block)
      select_map(-> (v) { !(pattern === v) }, &block)
    end

    def include?(obj)
      lift(Operations::Include.new(obj))
    end

    def lazy
      self # Just to comply with Enumerable
    end

    def wrap(**args)
      lift(Operations::Wrap.new(args))
    end

    def select(label: nil, &block)
      return self unless block_given?

      if label
        lift(Operations::OperationOnLabeled.new(label, block, op: :select))
      else
        lift(Operations::Select.new(block))
      end
    end

    def reject(&block)
      select(&->(val) { !block.call(val)} )
    end

    def inject(initial = NO_VALUE, label: nil, initial_value: NO_VALUE, &block)
      return self unless block_given?

      init = initial != NO_VALUE ? initial : initial_value
      if label
        lift(Operations::OperationOnLabeled.new(
          label, block, op: :inject, initial_value: init
        ))
      else
        lift(Operations::Inject.new(block, init))
      end
    end

    def each_with_object(obj, &block)
      lift(Operations::EachWithObject.new(block, obj))
    end

    def diff(initial = NO_VALUE, &block)
      lift(Operations::Diff.new(
        block_given? ? block : Operations::Diff::DEFAULT_FN, initial
      ))
    end

    def drop(how_many_to_drop)
      lift(Operations::Drop.new(how_many_to_drop))
    end

    def drop_while(&block)
      predicate = block_given? ? block : FALSE_PREDICATE
      lift(Operations::DropWhile.new(predicate))
    end

    def drop_errors
      lift(Operations::DropErrors.new)
    end

    def take(how_many_to_take)
      lift(Operations::Take.new(how_many_to_take))
    end

    def take_while(&block)
      return self unless block_given?

      lift(Operations::TakeWhile.new(block))
    end

    def uniq
      lift(Operations::Uniq.new)
    end

    def flatten
      lift(Operations::Flatten.new)
    end

    def first(n = 1)
      raise ArgumentError.new('negative array size') if n < 0

      take(n)
    end

    def [](x)
      lift(Operations::Drop.new(x, 1))
    end

    def last
      lift(Operations::Last.new)
    end

    def prepend(enumerable)
      lift(Operations::Prepend.new(enumerable))
    end

    def append(to_append, condition: nil)
      lift(Operations::Append.new(to_append, condition: condition))
    end

    def concat(trackable)
      lift(Operations::Concat.new(trackable))
    end

    def merge(*trackables, delay_error: false)
      lift(Operations::Merge.new(trackables, delay_error: delay_error))
    end

    def buffer(count: nil, delay: nil)
      lift(Operations::Buffer.new(count: count, delay: delay))
    end

    def delay(delay)
      buffer(delay: delay)
    end

    def delay_each(delay)
      lift(Operations::DelayEach.new(delay))
    end

    def throttle(delay)
      lift(Operations::Throttle.new(delay))
    end

    def depend_on(trackable, key: :data, &block)
      lift(Operations::DependOn.new(
        trackable, key: key, accumulator: block
      ))
    end

    def group_by_label(executor: nil, &block)
      lift(Operations::GroupByLabel.new(block, executor))
    end

    def flatten_labeled(initial: NO_VALUE, &block)
      lift(Operations::FlattenLabeled.new(block, initial))
    end

    def split_labeled(label, executor: nil, &block)
      lift(Operations::SplitLabeled.new(label, block, executor))
    end

    def act(on: Operations::Act::ALL, &block)
      lift(Operations::Act.new(block, on))
    end

    def retry(retries = 1)
      lift(Operations::Retry.new(@behaviour, retries))
    end

    def retry_when(&block)
      return self unless block_given?

      lift(Operations::RetryWhen.new(@behaviour, block))
    end

    def rescue_and_replace_error(&block)
      return self unless block_given?

      lift(Operations::RescueAndReplaceError.new(block))
    end

    def rescue_and_replace_error_with(trackable)
      rescue_and_replace_error { |_error| trackable }
    end

    def combine_last(*trackables, &block)
      return self unless block_given?

      self.class.combine_last(*([self] + trackables), &block)
    end

    def combine(*trackables, &block)
      return self unless block_given?

      self.class.combine(*([self] + trackables), &block)
    end

    def slice_after(pattern = NO_VALUE, &block)
      slice(pattern, type: :after, &block)
    end

    def slice_before(pattern = NO_VALUE, &block)
      slice(pattern, type: :before, &block)
    end

    def slice(pattern = NO_ACTION, type: type, &block)
      predicate =
        if pattern != NO_VALUE
          -> (val) { pattern === val }
        else
          block
        end
      lift(Operations::Slice.new(predicate, type: type))
    end

    def slice_when(&block)
      lift(Operations::SliceWhen.new(block))
    end

    def zip(*trackables, &block)
      self.class.zip(*([self] + trackables), &block)
    end

    def track_on(executor)
      stored = EXECUTOR_ALIASES[executor]
      executor = stored if stored

      lift(Operations::TrackOn.new(executor))
    end

    def execute_on(executor)
      stored = EXECUTOR_ALIASES[executor]
      executor = stored if stored

      self.class.new(executor, &@behaviour)
    end

    def await(subscription, timeout = nil)
      return unless subscription.subscribed?

      latch = Concurrent::CountDownLatch.new(1)
      subscription.add(Subscriptions.on_close_and_error { latch.count_down })

      latch.wait(timeout)
    rescue Exception => e
      raise e unless e.message.include?('No live threads left')
    end

    alias_method :skip, :drop
    alias_method :skip_errors, :drop_errors
    alias_method :collect, :map
    alias_method :collect_concat, :flat_map
    alias_method :detect, :find
    alias_method :each, :on
    alias_method :each_entry, :on
    alias_method :combine_latest, :combine
    alias_method :group_by, :group_by_label
    alias_method :find_all, :select
    alias_method :'member?', :'include?'
    alias_method :reduce, :inject

    def do_track(subscription)
      if @executor
        @executor.post(subscription, &@behaviour)
      else
        @behaviour.call(subscription)
      end
    end

    protected

    def create_lifted(&block)
      self.class.new(@executor, &block)
    end

    private

    def select_map(predicate, &block)
      result = select(&predicate)
      result = result.map(&block) if block_given?

      result
    end

    def retrieve_executor(executor)
      return nil if executor.nil?

      stored = EXECUTOR_ALIASES[executor]
      stored ? stored : executor
    end

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
