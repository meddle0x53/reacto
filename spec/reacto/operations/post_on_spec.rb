require 'spec_helper'

require 'reacto/operations/post_on'
require 'reacto/subscriptions/executor_subscription'
require 'reacto/executors'
require 'reacto/tracker'

describe Reacto::Operations::PostOn do

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

