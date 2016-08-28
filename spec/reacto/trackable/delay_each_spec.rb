context Reacto::Trackable do
  context '#delay_each' do
    it 'emits every notification from the source Trackable, but waits ' \
      'the given delay seconds for between every emit' do
      trackable = described_class.enumerable((1..5)).delay_each(0.3)

      trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )

      sleep 1
      expect(test_data).to eq([1, 2, 3])

      sleep 1
      expect(test_data).to eq([1, 2, 3, 4, 5, '|'])
    end
  end
end
