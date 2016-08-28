context Reacto::Trackable do
  context '#split_labeled' do
    it 'it turns a LabeledTrackable emitted by the source to multiple' \
      'LabeledTrackable instances with their own labels, computed by the' \
      'give block' do
      trackable =
        Reacto::Trackable.enumerable((1..10).each).group_by_label do |value|
          [(value <= 5) ? 'one to five' : 'six to ten', value]
        end

      trackable = trackable.split_labeled('one to five') do |value|
        [(value < 4) ? 'one to three' : 'four and five', value]
      end

      trackable.on(value: test_on_value)
      expect(test_data.size).to eq(3)

      one_to_three = test_data.first
      one_to_three_data = []
      one_to_three.on(value: ->(v) { one_to_three_data << v })
      expect(one_to_three.label).to eq('one to three')
      expect(one_to_three_data).to eq([1, 2, 3])

      four_and_five = test_data[1]
      four_and_five_data = []
      four_and_five.on(value: ->(v) { four_and_five_data << v })
      expect(four_and_five.label).to eq('four and five')
      expect(four_and_five_data).to eq([4, 5])

      six_to_ten = test_data.last
      six_to_ten_data = []
      six_to_ten.on(value: ->(v) { six_to_ten_data << v })
      expect(six_to_ten.label).to eq('six to ten')
      expect(six_to_ten_data).to eq((6..10).to_a)
    end
  end
end
