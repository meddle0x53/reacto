context Reacto::Trackable do
  context '#find' do
    subject(:source) { described_class.enumerable([0, 5, 2, 3, 4, 1, 6]) }

    it 'doesn\'t notify with values not passing the filter block' do
      trackable = source.find { |v| v > 10 }
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(0)
    end

    it 'notifies with the first value passing the filter block' do
      trackable = source.find do |v|
        v % 2 == 1
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(5)
    end

    it 'notifies with the given value if value is given and nothing is found' do
      trackable = source.find(15) do |v|
        v > 10
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(15)
    end
  end
end
