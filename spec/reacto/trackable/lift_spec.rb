context Reacto::Trackable do
  context '#lift' do
    it 'applies a transformation to the trackable behaviour' do
      lifted_trackable = source.lift do |tracker_subscription|
        Reacto::Subscriptions::OperationSubscription.new(
          tracker_subscription,
          value: -> (v) { tracker_subscription.on_value(v * v) }
        )
      end

      lifted_trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(25)
    end
  end
end
