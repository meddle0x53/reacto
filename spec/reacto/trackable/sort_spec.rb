context Reacto::Trackable do
  context '#sort' do
    subject(:test_source) { described_class.enumerable([5, 3, 8, 1, 2, 9, 10]) }

    it 'emits the values emitted by the source in sorted order, ' \
      'using the `<=>` operator of the values' do
      trackable = test_source.sort

      trackable.on(value: test_on_value)

      expect(test_data).to eq([1, 2, 3, 5, 8, 9, 10])
    end

    it 'emits the values emitted by the source in sorted order, ' \
      'using the passed block' do
      trackable = test_source.sort { |a, b|  b <=> a }

      trackable.on(value: test_on_value)

      expect(test_data).to eq([10, 9, 8, 5, 3, 2, 1])
    end
  end
end
