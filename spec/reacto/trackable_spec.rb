require 'spec_helper'

describe Reacto::Trackable do
  let(:test_data) { [] }
  let(:test_on_value) { -> (v) { test_data << v }}

  describe '.new' do
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

  describe '#on' do
    it 'returns a Reacto::Subscription' do
      actual = described_class.new(Reacto::NO_ACTION).on

      expect(actual).to_not be(nil)
      expect(actual).to be_kind_of(Reacto::Subscriptions::Subscription)
    end

    context('value') do
      it 'the trackable behavior uses a subscription which `on_value` is the passed value action' do
        behaviour = -> (s) do
          s.on_value(5)
        end
        described_class.new(behaviour).on(value: test_on_value)

        expect(test_data.size).to be(1)
        expect(test_data[0]).to be(5)
      end
    end
  end
end
