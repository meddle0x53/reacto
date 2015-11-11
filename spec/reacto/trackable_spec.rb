require 'spec_helper'

describe Reacto::Trackable do

  context 'subscribtion bahaviour' do
  end

  describe '#on' do
    it 'returns a Reacto::Subscription' do
      actual = described_class.new(Reacto::NO_ACTION).on

      expect(actual).to_not be(nil)
      expect(actual).to be_kind_of(Reacto::Subscription)
    end

    context('value') do
      it 'the trackable behavior uses a subscription which `on_value` is the passed value action' do
        test_data = []
        behaviour = -> (s) do
          s.on_value(5)
        end
        described_class.new(behaviour).on(value: -> (v) { test_data << v })

        expect(test_data.size).to be(1)
        expect(test_data[0]).to be(5)
      end
    end
  end
end
