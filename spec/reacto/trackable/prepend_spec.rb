require 'spec_helper'

context Reacto::Trackable do
  context '#prepend' do
    it 'emits the passed enumerable before the values, emited by the caller' do
      source = described_class.enumerable((1..5))
      trackable = source.prepend((-5..0))

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(11)
      expect(test_data).to be == (-5..5).to_a
    end
  end
end
