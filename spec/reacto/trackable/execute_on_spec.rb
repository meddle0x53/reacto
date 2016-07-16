require 'spec_helper'

context Reacto::Trackable do
  subject do
   described_class.new do |tracker_subscription|
      tracker_subscription.on_value(32)
      sleep 1

      tracker_subscription.on_close
    end
  end

  context '#execute_on' do
    it 'executes the whole chain of methods on a background managed thread' do
      threads = []

      trackable = subject
        .act { |n| threads << Thread.current }
        .map { |v| v / 8 }
        .execute_on(:background)

      subscription = attach_test_trackers(trackable)
      trackable.await(subscription)

      expect(test_data).to eq([4, '|'])

      threads = threads.uniq
      expect(threads.size).to be(1)

      thread = threads.first

      expect(thread).to_not be(Thread.current)
    end
  end
end
