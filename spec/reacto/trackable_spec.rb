require 'spec_helper'

context Reacto::Trackable do
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

  context '#drop_errors' do
    it 'drops all the errors from the source and continues' do
      described_class.enumerable((1..5)).concat(
        described_class.error(StandardError.new)
      ).concat(described_class.enumerable(6..10)).drop_errors.on(
        value: test_on_value, error: test_on_error, close: test_on_close
      )

      expect(test_data).to be == (1..10).to_a + ['|']
    end
  end
end
