require 'spec_helper'

context Reacto::Trackable do
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
    it 'executes the trackable behaviour on the passed executor' do
      subject
      .execute_on(Reacto::Executors.io)
      .map(-> (v) { v * 2 })
      .on(value: test_on_value, close: test_on_close)
    end
  end
end
