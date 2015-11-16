require 'spec_helper'

context Reacto::Trackable do

  let(:test_data) { [] }
  let(:test_on_value) { -> (v) { p v; test_data << v }}
  let(:test_on_close) { -> () { test_data << '|' }}

  subject do
   described_class.new do |tracker_subscription|
      tracker_subscription.on_value(16)
      sleep 1

      tracker_subscription.on_value(7)
      sleep 2

      tracker_subscription.on_value(2014)
      sleep 3

      tracker_subscription.on_close
    end
  end

  context '#track_on' do
    it 'executes the trackable login on the passed executor' do
      subject
      .track_on(Reacto::Executors.io)
      .on(value: test_on_value, close: test_on_close)

      p test_data
    end
  end
end
