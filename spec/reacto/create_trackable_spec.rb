require 'spec_helper'

context Reacto::Trackable do

  let(:test_data) { [] }
  let(:test_on_value) { -> (v) { test_data << v }}
  let(:test_on_close) { -> () { test_data << '|' }}
  let(:test_on_error) { -> (e) { test_data << e }}

  def attach_test_trackers(trackable)
    trackable.on(
      value: test_on_value,
      error: test_on_error,
      close: test_on_close
    )
  end

  context '.never' do
    it 'creates a new trackable, which won\'t send any notifications' do
      attach_test_trackers described_class.never

      expect(test_data).to be_empty
    end
  end
end
