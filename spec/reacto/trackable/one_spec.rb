context Reacto::Trackable do
  context '#one?' do
    it 'passes each incoming value to the given block. The resulting ' \
      'Reacto::Trackable emits only one value - `true` if the block returns ' \
      '`true` exactly once. Test true.' do
      trackable = described_class.enumerable((5..10)).one? do |value|
        value < 6
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(true)
    end

    it 'passes each incoming value to the given block. The resulting ' \
      'Reacto::Trackable emits only one value - `true` if the block returns ' \
      '`true` exactly once. Test false.' do
      trackable = described_class.enumerable((4..10)).one? do |value|
        value < 6
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(false)
    end

    it 'if the block is not given, adds an implicit block of { |obj| obj }' do
      trackable = described_class.enumerable([0, nil, 1]).one?

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(false)
    end
  end
end
