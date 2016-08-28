context Reacto::Trackable do
  context '#sort_by' do
    subject(:test_source) do
      described_class.enumerable(%w(elephant fox lion dog wolf))
    end

    it 'emits the values emitted by the source in sorted order, ' \
      'using the value returned by the given block for comparison' do
      trackable = test_source.sort_by { |word| word.length }

      trackable.on(value: test_on_value)

      expect(test_data).to eq(%w(dog fox wolf lion elephant))
    end
  end
end
