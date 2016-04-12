require 'spec_helper'

context Reacto::Trackable do
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
end
