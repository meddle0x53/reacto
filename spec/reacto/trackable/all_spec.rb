context Reacto::Trackable do
  context '#all?' do
    it 'passes each incoming value to the given block. The resulting ' \
      'Reacto::Trackable emits only one value - `true` if the block never ' \
      'returns `false` or `nil`. Test true.' do
      trackable = described_class.enumerable((1..5)).all? do |value|
        value < 6
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(true)
    end

    it 'passes each incoming value to the given block. The resulting ' \
      'Reacto::Trackable emits only one value - `true` if the block never ' \
      'returns `false` or `nil`. Test false.' do
      trackable = described_class.enumerable((1..7)).all? do |value|
        value < 6
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(false)
    end

    it 'if the block is not given, adds an implicit block of { |obj| obj }' do
      trackable = described_class.enumerable((1..7)).all?

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(true)
    end
  end
end
