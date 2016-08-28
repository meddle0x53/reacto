context Reacto::Trackable do
  context '#uniq' do
    it 'sends only uniq values, dropping the repeating ones' do
      trackable =
        described_class.enumerable([1, 2, 3, 2, 4, 3, 2, 1, 5]).uniq

      trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )
      expect(test_data).to eq([1, 2, 3, 4, 5, '|'])
    end
  end
end
