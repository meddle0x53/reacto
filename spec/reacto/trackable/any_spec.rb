context Reacto::Trackable do
  context '#any?' do
    it 'passes each incoming value to the given block. The resulting ' \
      'Reacto::Trackable emits only one value - `true` if the block returns ' \
      'even one `true`. Test true.' do
      trackable = described_class.enumerable((5..10)).any? do |value|
        value < 6
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(true)
    end

    it 'passes each incoming value to the given block. The resulting ' \
      'Reacto::Trackable emits only one value - `true` if the block returns ' \
      'even one `true`. Test false.' do
      trackable = described_class.enumerable((6..10)).any? do |value|
        value < 6
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(false)
    end

    it 'if the block is not given, adds an implicit block of { |obj| obj }' do
      trackable = described_class.enumerable([nil, nil]).any?

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(false)
    end
  end
end
