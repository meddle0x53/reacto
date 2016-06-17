require 'spec_helper'

context Reacto::Trackable do
  context '#act' do
    it 'can be used to do something with the currently incloming data, ' \
      'without changing it (if imuttable), for example logging' do
      notifications = []

      trackable = described_class.enumerable((1..20)).act do |notification|
        notifications << notification
      end
      trackable.on(value: test_on_value)

      expect(notifications.size).to eq(21)
    end
  end
end
