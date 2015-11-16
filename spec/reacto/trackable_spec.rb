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
      trackable = described_class.new(test_behaviour)
      lifted_trackable = trackable.lift do |tracker_subscription|
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
      source = described_class.new(test_behaviour)
      trackable = source.map do |v|
        v * v * v
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data[0]).to be(125)
    end
  end
end
