context Reacto::Trackable do
  context '#flatten_labeled' do
    it 'transfomrs the LabeledTrackable instances emitted into objects with' \
      'two attributes - label the label of the LabeledTrackable and value -' \
      'the first value of emitted by the LabeledTrackable' do
      trackable = described_class.enumerable((1..10)).group_by_label do |value|
        [(value % 3), value]
      end
      trackable = trackable.flatten_labeled

      trackable.on(value: test_on_value)

      expect(test_data.count).to eq(3)
      expect(test_data.map(&:value)).to eq([1, 2, 3])
    end

    it 'transfomrs the LabeledTrackable instances emitted into objects with' \
      'two attributes - label the label of the LabeledTrackable and value -' \
      'the last value computed by the passed accumulator block' do
      trackable = described_class.enumerable((1..10)).group_by_label do |value|
        [(value % 3), value]
      end
      trackable = trackable.flatten_labeled { |prev, curr| prev + curr }

      trackable.on(value: test_on_value)

      expect(test_data.count).to eq(3)
      expect(test_data.map(&:value)).to eq([22, 15, 18])
    end

    it 'transfomrs the LabeledTrackable instances emitted into objects with' \
      'two attributes - label the label of the LabeledTrackable and value -' \
      'the last value computed by the passed accumulator block, using the ' \
      'passed initial value' do
      trackable = described_class.enumerable((1..10)).group_by_label do |value|
        [(value % 3), value]
      end
      trackable = trackable.flatten_labeled(initial: -10) do |prev, curr|
        prev + curr
      end

      trackable.on(value: test_on_value)

      expect(test_data.count).to eq(3)
      expect(test_data.map(&:value)).to eq([12, 5, 8])
    end
  end
end
