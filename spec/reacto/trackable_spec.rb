require 'spec_helper'

context Reacto::Trackable do
  let(:test_data) { [] }
  let(:test_on_value) { -> (v) { test_data << v }}

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

  context '#drop & #take' do
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
  end
end
