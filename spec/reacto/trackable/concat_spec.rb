context Reacto::Trackable do
  subject(:test_source) { described_class.enumerable((1..5)) }

  context '#concat' do
    it 'starts emitting the values from the concatenated after emitting the ' \
      'values from the source, then emits a `close` notification' do
      trackable = test_source.concat(described_class.enumerable((6..10)))
      trackable.on(value: test_on_value, close: test_on_close)

      expect(test_data).to eq((1..10).to_a + ['|'])
    end

    it 'can be chained' do
      trackable = test_source
        .concat(described_class.enumerable((6..8)))
        .concat(described_class.enumerable((9..10)))
      trackable.on(value: test_on_value, close: test_on_close)

      expect(test_data).to eq((1..10).to_a + ['|'])
    end

    it 'closes on error' do
      err = StandardError.new('Hey')
      trackable = test_source
        .concat(described_class.error(err))
        .concat(described_class.enumerable((9..10)))
      trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )

      expect(test_data).to eq([1, 2, 3, 4, 5, err])
    end
  end
end
