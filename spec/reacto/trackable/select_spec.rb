context Reacto::Trackable do
  context '#select' do
    it 'doesn\'t notify with values not passing the filter block' do
      trackable = source.select(&:even?)
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(0)
    end

    it 'notifies with values passing the filter block' do
      trackable = source.select(&:odd?)

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(5)
    end

    context 'with label' do
      it 'applies the filtering passed only to the emitted values of type ' \
        'LabeledTrackable with the matching label' do
        source = described_class.enumerable((1..10)).group_by_label do |value|
          [(value % 3), value]
        end

        trackable = source.select(label: 1) { |value| value < 5 }
        trackable.on(value: test_on_value)

        expect_trackable_values(test_data.first, [1, 4], label: 1)
        expect_trackable_values(test_data[1], [2, 5, 8], label: 2)
        expect_trackable_values(test_data.last, [3, 6, 9], label: 0)
      end
    end
  end
end
