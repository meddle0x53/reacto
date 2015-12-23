require 'spec_helper'

context Reacto::Trackable do

  let(:test_data) { [] }
  let(:test_on_value) { -> (v) { test_data << v }}
  let(:test_on_close) { -> () { test_data << '|' }}
  let(:test_on_error) { -> (e) { test_data << e }}

  def attach_test_trackers(trackable)
    trackable.on(
      value: test_on_value,
      error: test_on_error,
      close: test_on_close
    )
  end

  context '.never' do
    it 'creates a new trackable, which won\'t send any notifications' do
      attach_test_trackers described_class.never

      expect(test_data).to be_empty
    end
  end

  context '.error' do
    it 'creates a new trackable emitting only the error passed' do
      err = StandardError.new('Errrr')
      attach_test_trackers described_class.error(err)

      expect(test_data).to be == [err]
    end
  end

  context '.make' do
    it 'creates a new trackable with custom behaviour passed as lambda' do
      behaviour = lambda do |tracker|
        (1..10).each do |v|
          tracker.on_value(v)
        end

        tracker.on_close
      end

      attach_test_trackers described_class.make(behaviour)

      expect(test_data.size).to be(11)
      expect(test_data).to be == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, '|']
    end

    it 'creates a new trackable with custom behaviour passed as block' do
      trackable = described_class.make do |tracker|
        (1..10).each do |v|
          tracker.on_value(v)
        end

        tracker.on_close
      end
      attach_test_trackers trackable

      expect(test_data.size).to be(11)
      expect(test_data).to be == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, '|']
    end

    it 'does not emit anything once it is closed' do
      trackable = described_class.make do |tracker|
        (1..5).each do |v|
          tracker.on_value(v)
        end

        tracker.on_close

        (1..5).each do |v|
          tracker.on_value(v)
        end
      end
      attach_test_trackers trackable

      expect(test_data.size).to be(6)
      expect(test_data).to be == [1, 2, 3, 4, 5, '|']
    end

    it 'does not emit anything once it has an error' do
      trackable = described_class.make do |tracker|
        (1..5).each do |v|
          tracker.on_value(v)
        end

        tracker.on_error('error')

        (1..5).each do |v|
          tracker.on_value(v)
        end
      end
      attach_test_trackers trackable

      expect(test_data.size).to be(6)
      expect(test_data).to be == [1, 2, 3, 4, 5, 'error']
    end

    it 'emits the same behaviour for every subscribe' do
      trackable = described_class.make do |tracker|
        (1..5).each do |v|
          tracker.on_value(v)
        end

        tracker.on_close
      end
      attach_test_trackers trackable
      attach_test_trackers trackable

      expect(test_data.size).to be(12)
      expect(test_data).to be == [1, 2, 3, 4, 5, '|', 1, 2, 3, 4, 5, '|']
    end
  end

  context '.later' do
    it 'emits the passed value after the passed time runs out and then emits ' \
      'a close notification' do
      trackable = described_class.later(0.2, 5)
      subscription = attach_test_trackers(trackable)

      expect(test_data).to be_empty
      trackable.await(subscription)
      expect(test_data).to be == [5, '|']
    end

    it 'it can use a specific executor' do
      trackable = described_class.later(
        0.2, 5, executor: Reacto::Executors.immediate
      )
      subscription = attach_test_trackers(trackable)
      expect(test_data).to be == [5, '|']
    end
  end

  context '.interval' do
    it 'emits an infinite sequence of number on every n seconds by default' do
      trackable = described_class.interval(0.1)
      subscription = attach_test_trackers(trackable)
      sleep 1
      subscription.unsubscribe

      expect(test_data).to be == (0..8).to_a
    end

    it 'can use any enumerator to produce the sequence to emit' do
      trackable = described_class.interval(0.1, ('a'..'z').each)
      subscription = attach_test_trackers(trackable)
      sleep 1
      subscription.unsubscribe

      expect(test_data).to be == ('a'..'i').to_a
    end

    it 'can use the immediate executor to block the current thread while ' \
      'emitting' do
      trackable = described_class.interval(
        0.1, (1..5).each, executor: Reacto::Executors.immediate
      )
      subscription = attach_test_trackers(trackable)

      expect(test_data).to be == (1..5).to_a + ['|']
    end
  end

  context '.value' do
    it 'emits only the passed value and then closes' do
      trackable = described_class.value(5)
      subscription = attach_test_trackers(trackable)

      expect(test_data).to be == [5, '|']
    end
  end

  context '.enumerable' do
    it 'emits the whole enumerable one-by-one and then closes' do
      trackable = described_class.enumerable([1, 3, 5, 6, 7, 8])
      subscription = attach_test_trackers(trackable)

      expect(test_data).to be == [1, 3, 5, 6, 7, 8, '|']
    end

    it 'on error it emits all til the error and the error' do
      class PositiveArray
        include Enumerable

        def error
          @error ||= StandardError.new('Bad.')
        end

        def initialize(*members)
          @members = members
        end

        def each(&block)
          @members.each do |member|
            raise error if member < 0
            block.call(member)
          end
        end
      end

      enumerable = PositiveArray.new(2, 3, -4, 3, 6)
      trackable = described_class.enumerable(enumerable)
      subscription = attach_test_trackers(trackable)

      expect(test_data).to be == [2, 3, enumerable.error]

    end
  end
end
