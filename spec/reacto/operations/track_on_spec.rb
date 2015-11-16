require 'spec_helper'

describe Reacto::Operations::TrackOn do

  subject do
    described_class.new(Reacto::Executors.immediate)
  end

  context '#call' do
    it 'returns a special ExecutorSubscription' do
      subscription = subject.call(Reacto::Tracker.new)

      expect(subscription).to(
        be_instance_of(Reacto::Subscriptions::ExecutorSubscription)
      )
    end
  end

end

