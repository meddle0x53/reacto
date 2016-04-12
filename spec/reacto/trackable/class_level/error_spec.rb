require 'spec_helper'

context Reacto::Trackable do
  context '.error' do
    it 'creates a new trackable emitting only the error passed' do
      err = StandardError.new('Errrr')
      attach_test_trackers described_class.error(err)

      expect(test_data).to be == [err]
    end
  end
end
