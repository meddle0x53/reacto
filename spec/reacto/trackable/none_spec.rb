context Reacto::Trackable do
  context '#none?' do
    it 'passes each incoming value to the given block. The resulting ' \
      'Reacto::Trackable emits only one value - `true` if the block never ' \
      'returns `true`. Test true.' do
      trackable = described_class.enumerable((5..10)).none? do |value|
        value < 5
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(true)
    end

    it 'passes each incoming value to the given block. The resulting ' \
      'Reacto::Trackable emits only one value - `true` if the block never ' \
      'returns `true`. Test false.' do
      trackable = described_class.enumerable((6..10)).none? do |value|
        value < 7
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(false)
    end

    it 'if the block is not given, adds an implicit block of { |obj| obj }' do
      trackable = described_class.enumerable([nil, nil]).none?

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(true)
    end
  end
end
