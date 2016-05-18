context Reacto::Trackable do
  context '#label' do
    it 'transforms each of the values emitted by the source into ' \
      'LabeledTrackable instances, using the passed function to get their ' \
      'labels and values to emit' do
        trackable =
          Reacto::Trackable.enumerable((1..10).each).label do |value|
            [(value % 3), value]
          end

      trackable.on(value: test_on_value)

      expect(test_data.count).to eq(3)

      one = test_data.first
      expect(one.label).to eq(1)
      one_array = []
      one.on(value: ->(v) { one_array << v })
      expect(one_array).to eq([1, 4, 7, 10])

      two = test_data[1]
      expect(two.label).to eq(2)
      two_array = []
      two.on(value: ->(v) { two_array << v })
      expect(two_array).to eq([2, 5, 8])

      two = test_data[1]
      expect(two.label).to eq(2)
      two_array = []
      two.on(value: ->(v) { two_array << v })
      expect(two_array).to eq([2, 5, 8])

      zero = test_data.last
      expect(zero.label).to eq(0)
      zero_array = []
      zero.on(value: ->(v) { zero_array << v })
      expect(zero_array).to eq([3, 6, 9])
    end
  end
end
