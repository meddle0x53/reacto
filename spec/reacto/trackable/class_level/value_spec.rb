require 'spec_helper'

context Reacto::Trackable do
  context '.value' do
    it 'emits only the passed value and then closes' do
      trackable = described_class.value(5)
      attach_test_trackers(trackable)

      expect(test_data).to be == [5, '|']
    end
  end
end
