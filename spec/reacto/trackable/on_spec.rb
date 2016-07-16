require 'spec_helper'

context Reacto::Trackable do
  context '#on' do
    it 'returns a Reacto::Subscription' do
      actual = described_class.new.on

      expect(actual).to_not be(nil)
      expect(actual).to be_kind_of(Reacto::Subscriptions::Subscription)
    end

    context('value') do
      it 'the trackable behavior uses a subscription which `on_value` ' \
        'is the passed value action' do
        described_class.new(&test_behaviour).on(value: test_on_value)

        expect(test_data.size).to be(1)
        expect(test_data[0]).to be(5)
      end
    end

    context 'with block' do
      it 'behaves as #on value: <lambda>' do
        described_class.new(&test_behaviour).on(&test_on_value)

        expect(test_data.size).to be(1)
        expect(test_data[0]).to be(5)
      end
    end
  end
end
