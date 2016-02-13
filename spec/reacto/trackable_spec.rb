require 'spec_helper'

context Reacto::Trackable do
  let(:test_data) { [] }
  let(:test_on_value) { -> (v) { test_data << v }}
  let(:test_on_error) { -> (e) { test_data << e }}
  let(:test_on_close) { -> () { test_data << '|' }}

  let(:test_behaviour) do
    lambda do |tracker_subscription|
      tracker_subscription.on_value(5)
      tracker_subscription.on_close
    end
  end

  let(:source) { described_class.new(test_behaviour) }

  context '.new' do
    it 'supports behavior invoked on tracking, passed as block' do
      trackable = described_class.new do |tracker_subscription|
        tracker_subscription.on_value(4)
        tracker_subscription.on_close
      end

      trackable.on(value: test_on_value)
      expect(test_data.size).to be(1)
      expect(test_data[0]).to be(4)
    end
  end

  context '#on' do
    it 'returns a Reacto::Subscription' do
      actual = described_class.new(Reacto::NO_ACTION).on

      expect(actual).to_not be(nil)
      expect(actual).to be_kind_of(Reacto::Subscriptions::Subscription)
    end

    context('value') do
      it 'the trackable behavior uses a subscription which `on_value` ' \
        'is the passed value action' do
        described_class.new(test_behaviour).on(value: test_on_value)

        expect(test_data.size).to be(1)
        expect(test_data[0]).to be(5)
      end
    end
  end

  context '#lift' do
    it 'applies a transformation to the trackable behaviour' do
      lifted_trackable = source.lift do |tracker_subscription|
        Reacto::Subscriptions::OperationSubscription.new(
          tracker_subscription,
          value: -> (v) { tracker_subscription.on_value(v * v) }
        )
      end

      lifted_trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data[0]).to be(25)
    end
  end

  context '#map' do
    it 'transforms the value of the source Trackable using the passed ' \
      'transformation' do
      trackable = source.map do |v|
        v * v * v
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data[0]).to be(125)
    end

    it 'transforms errors, if error transformation is passed' do
      source = described_class.make do |subscriber|
        subscriber.on_value(4)
        subscriber.on_error(StandardError.new('error'))
      end
      trackable = source.map(-> (v) { v }, error: -> (e) { 5 })

      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data.size).to be(2)
      expect(test_data).to be == [4, 5]
    end

    it 'emits what is produced by the passed `close` function before close' do
      trackable =
        described_class.enumerable((1..5)).map(close: ->() { 10 }) do |v|
          v
        end

      trackable.on(value: test_on_value, close: test_on_close)
      expect(test_data).to be == (1..5).to_a + [10, '|']
    end
  end

  context '#select' do
    it 'doesn\'t notify with values not passing the filter block' do
      trackable = source.select do |v|
        v % 2 == 0
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(0)
    end

    it 'notifies with values passing the filter block' do
      trackable = source.select do |v|
        v % 2 == 1
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data[0]).to be(5)
    end
  end

  context '#inject' do
    let(:test_behaviour) do
      lambda do |tracker_subscription|
        [16, 7, 2014].each do |value|
          tracker_subscription.on_value(value)
        end

        tracker_subscription.on_close
      end
    end

    it 'sends the values created by applying the `inject` operation on the ' \
      'last value and current value, using for first value the initial one' do
      trackable = source.inject(0) do |prev, v|
        prev + v
      end
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(3)
      expect(test_data).to be == [16, 23, 2037]
    end

    it 'sends the values created by applying the `inject` operation on the ' \
      'last value and current value, using for first value ' \
      'the first emitted by the source if no initial value provided' do
      trackable = source.inject do |prev, v|
        prev + v
      end
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(3)
      expect(test_data).to be == [16, 23, 2037]
    end

    it 'sends the initial value if no value is emitted' do
      source = described_class.new(-> (t) { t.on_close })
      trackable = source.inject(0) do |prev, v|
        prev + v
      end
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data).to be == [0]
    end

    it 'sends nothing if no initial value and no value emitted' do
      source = described_class.new(-> (t) { t.on_close })
      trackable = source.inject do |prev, v|
        prev + v
      end
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(0)
    end
  end

  context '#diff' do
    it 'by default emits arrays with two values the - previous and current ' \
      'element' do
      source = described_class.enumerable((1..10))
      trackable = source.diff
      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data).to be == [
        [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10
      ]]
    end

    it 'can be passed a diff function to calculate the difference between ' \
      'the previously emitted value and the current and to emit it' do
      source = described_class.enumerable((1..10))
      trackable = source.diff(Reacto::NO_VALUE, -> (p, c) { c - p })
      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data).to be == [1] * 9
    end

    it 'can be passed a diff block to calculate the difference between ' \
      'the previously emitted value and the current and to emit it' do
      source = described_class.enumerable((1..10))
      trackable = source.diff { |p, c| c - p }
      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data).to be == [1] * 9
    end

    it 'can receive initial value to be used as seed - the first value' do
      source = described_class.enumerable((1..10))
      trackable = source.diff(-5) { |p, c| c - p }
      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data).to be == [6] + ([1] * 9)
    end
  end

  context '#prepend' do
    it 'emits the passed enumerable before the values, emited by the caller' do
      source = described_class.enumerable((1..5))
      trackable = source.prepend((-5..0))

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(11)
      expect(test_data).to be == (-5..5).to_a
    end
  end

  context '#drop, #take, #last, #first, #[]' do
    let(:test_behaviour) do
      lambda do |tracker_subscription|
        (1..15).each do |value|
          tracker_subscription.on_value(value)
        end

        tracker_subscription.on_close
      end
    end

    context('#drop') do
      it 'drops the first `n` values sent by the source' do
        source.drop(6).on(value: test_on_value)

        expect(test_data.size).to be(9)
        expect(test_data).to be == (7..15).to_a
      end
    end

    context('#take') do
      it 'sents only the first `n` values sent by the source' do
        source.take(6).on(value: test_on_value)

        expect(test_data.size).to be(6)
        expect(test_data).to be == (1..6).to_a
      end
    end

    context('#last') do
      it 'emits only the last value of the source and the closing ' \
        'notification' do
        source.last.on(value: test_on_value, close: test_on_close)

        expect(test_data).to be == [15, '|']
      end

      it 'only closes if no value was emitted by the source' do
        described_class.close.last.on(
          value: test_on_value, close: test_on_close
        )

        expect(test_data).to be == ['|']
      end

      it 'emits the last value before the error and the error when error ' \
        'notification is received from the source' do
        err = StandardError.new('Hey!')
        source.concat(described_class.error(err)).last.on(
          value: test_on_value, close: test_on_close, error: test_on_error
        )

        expect(test_data).to be == [15, err]
      end
    end

    context('#first') do
      it 'emits only the first value of the source and closes' do
        source.first.on(
          value: test_on_value, close: test_on_close
        )

        expect(test_data).to be == [1, '|']
      end

      it 'only closes if no value was emitted by the source' do
        described_class.close.first.on(
          value: test_on_value, close: test_on_close
        )

        expect(test_data).to be == ['|']
      end
    end

    context('#[]') do
      it 'emits only the n-th value of the source and closes' do
        source[4].on(
          value: test_on_value, close: test_on_close
        )

        expect(test_data).to be == [5, '|']
      end

    end
  end

  context '#concat' do
    it 'starts emitting the values from the concatenated after emitting the ' \
      'values from the source, then emits a `close` notification' do
      trackable = source.concat(described_class.enumerable((6..10)))
      trackable.on(value: test_on_value, close: test_on_close)

      expect(test_data).to be == (5..10).to_a + ['|']
    end

    it 'can be chained' do
      trackable = source
      .concat(described_class.enumerable((6..8)))
      .concat(described_class.enumerable((9..10)))
      trackable.on(value: test_on_value, close: test_on_close)

      expect(test_data).to be == (5..10).to_a + ['|']
    end

    it 'closes on error' do
      err = StandardError.new('Hey')
      trackable = source
      .concat(described_class.error(err))
      .concat(described_class.enumerable((9..10)))
      trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )

      expect(test_data).to be == [5, err]
    end

    context '#merge' do
      it 'merges the passed trackable\'s emitions with the source ones' do
        trackable =
          described_class.interval(0.2).map { |v| v.to_s + 'a'}.take(5)
        to_be_merged =
          described_class.interval(0.35).map { |v| v.to_s + 'b'}.take(4)
        subscription = trackable.merge(to_be_merged).on(
          value: test_on_value, close: test_on_close, error: test_on_error
        )
        trackable.await(subscription)

        expect(test_data).to be ==
          ["0a", "0b", "1a", "2a", "1b", "3a", "4a", "2b", "3b", "|"]
      end

      it 'finishes with the error if `delay_error` is true' do
        err = StandardError.new('Hey')
        trackable = described_class.interval(0.2).map do |v|
          raise err if v == 3
          v.to_s + 'a'
        end.take(5)

        to_be_merged =
          described_class.interval(0.35).map { |v| v.to_s + 'b'}.take(4)

        trackable = trackable.merge(to_be_merged, delay_error: true)
        subscription = trackable.on(
          value: test_on_value, close: test_on_close, error: test_on_error
        )
        trackable.await(subscription, 2)

        expect(test_data).to be ==
          ["0a", "0b", "1a", "2a", "1b", "2b", "3b", err]

      end
    end

    context '#buffer' do
      context 'count' do
        it 'sends values on batches with the size of the passed count' do
          trackable = described_class.enumerable((1..20)).buffer(count: 5)
          trackable.on(
            value: test_on_value, close: test_on_close, error: test_on_error
          )

          expect(test_data).to be ==
            [(1..5).to_a, (6..10).to_a, (11..15).to_a, (16..20).to_a, '|']
        end
      end

      context 'delay' do
        it 'sends values on batches on intervals - the passed delay' do
          trackable = described_class.interval(0.1).take(20).buffer(delay: 0.5)
          subscription = trackable.on(
            value: test_on_value, close: test_on_close, error: test_on_error
          )
          trackable.await(subscription)
          expect(test_data).to be ==
            [
              [0, 1, 2, 3],
              [4, 5, 6, 7, 8],
              [9, 10, 11, 12, 13],
              [14, 15, 16, 17, 18],
              [19],
              "|"
          ]
        end
      end

      context 'count & delay' do
        it 'uses either the count or the delay to buffer and send' do
          trackable = described_class.make do |subscriber|
            subscriber.on_value(1)
            subscriber.on_value(2)
            subscriber.on_value(3)
            subscriber.on_value(4)
            subscriber.on_value(5)
            sleep 1
            subscriber.on_value(6)
            subscriber.on_close
          end.buffer(delay: 0.5, count: 3)

          trackable.on(
            value: test_on_value, close: test_on_close, error: test_on_error
          )
          expect(test_data).to be ==
            [[1, 2, 3], [4, 5], [6], '|']
        end
      end

      context 'uniq' do
        it 'sends only uniq values, dropping the repeating ones' do
          trackable =
            described_class.enumerable([1, 2, 3, 2, 4, 3, 2, 1, 5]).uniq

          trackable.on(
            value: test_on_value, close: test_on_close, error: test_on_error
          )
          expect(test_data).to be == [1, 2, 3, 4, 5, '|']
        end
      end

      context 'flatten' do
        it 'sends the members of array values as values' do
          trackable =
            described_class.enumerable([[1, 2, 3], [4, 3], [2, 1, 5]]).flatten

          trackable.on(
            value: test_on_value, close: test_on_close, error: test_on_error
          )
          expect(test_data).to be == [1, 2, 3, 4, 3, 2, 1, 5, '|']
        end
      end
    end
  end
end
