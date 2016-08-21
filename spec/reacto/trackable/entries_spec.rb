context Reacto::Trackable do
  context '#entries' do
    subject(:test_source) do
      described_class.enumerable((1..100))
    end

    it 'returns an array containing all the values emitted by the source' do
      result = test_source.entries

      expect(result).to eq((1..100).to_a)
    end

    it 'returns an array containing the first <n> values emitted by the ' \
      'source if a number is given' do
      result = test_source.entries(5)

      expect(result).to eq([1, 2, 3, 4, 5])
    end

    it 'blocks and waits for the array to be ready even if the source is ' \
      'executing on background executor' do
      result = test_source.delay_each(0.2).entries(3)

      expect(result).to eq([1, 2, 3])
    end
  end
end
