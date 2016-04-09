require 'spec_helper'

context Reacto::Trackable do
  context '.never' do
    it 'creates a new trackable, which won\'t send any notifications' do
      attach_test_trackers described_class.never

      expect(test_data).to be_empty
    end
  end
end
