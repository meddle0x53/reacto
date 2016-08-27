context Reacto::Trackable do
  context '#map' do
    it 'transforms the value of the source Trackable using the passed ' \
      'transformation' do
      trackable = source.map do |v|
        v * v * v
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data[0]).to be(125)
    end

    it 'transforms errors, if error transformation is passed' do
      source = described_class.make do |subscriber|
        subscriber.on_value(4)
        subscriber.on_error(StandardError.new('error'))
      end
      trackable = source.map(error: -> (e) { 5 }, &-> (v) { v })

      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data.size).to be(2)
      expect(test_data).to be == [4, 5]
    end

    it 'emits what is produced by the passed `close` function before close' do
      trackable =
        described_class.enumerable((1..5)).map(close: ->() { 10 }) do |v|
          v
        end

      trackable.on(value: test_on_value, close: test_on_close)
      expect(test_data).to eq((1..5).to_a + [10, '|'])
    end

    context 'with label' do
      it 'applies the mapping passed only to the incoming values of type ' \
        'LabeledTrackable with the matching label' do
        source = described_class.enumerable((1..10)).group_by_label do |value|
          [(value % 3), value]
        end

        trackable = source.map(label: 1) { |value| value / 3 }
        trackable.on(value: test_on_value)

        labeled_trackable = test_data.first
        expect(labeled_trackable.label).to eq(1)

        labeled_data = []
        labeled_trackable.on(value: ->(v) { labeled_data << v })
        expect(labeled_data).to eq([1 / 3, 4 / 3, 7 / 3, 10 / 3])
      end
    end
  end
end
