context Reacto::Trackable do
  context '#throttle' do
    it 'emits only the last values received after a given timeout' do
      trackable = described_class.interval(0.1).take(30).throttle(0.5)
      subscription = trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )
      trackable.await(subscription)

      expect(test_data.size).to eq(7)
    end
  end
end
