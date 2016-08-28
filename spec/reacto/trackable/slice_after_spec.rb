context Reacto::Trackable do
  context '#slice_after' do
    subject(:test_source) do
      described_class.enumerable(['A', 'B', 0, 'C', 2, true, false, 3, 'DE'])
    end

    it 'emits Reacto::Trackable instances emitting slices of the values, ' \
      'emitted by the source. The slices are determined by the last value ' \
      'for which <pattern> === value is true' do
      trackable = test_source.slice_after(Integer)

      attach_test_trackers(trackable)

      expect(test_data.size).to eq(5)
      expect_trackable_values(test_data.first, ['A', 'B', 0])
      expect_trackable_values(test_data[1], ['C', 2])
      expect_trackable_values(test_data[2], [true, false, 3])
      expect_trackable_values(test_data[3], %w(DE))
      expect(test_data.last).to eq('|')
    end

    it 'emits Reacto::Trackable instances emitting slices of the values, ' \
      'emitted by the source. The slices are determined by the last value ' \
      'the block given returns true' do
      trackable = test_source.slice_after do |val|
        val == false || val == 0
      end

      attach_test_trackers(trackable)

      expect(test_data.size).to eq(4)
      expect_trackable_values(test_data.first, ['A', 'B', 0])
      expect_trackable_values(test_data[1], ['C', 2, true, false])
      expect_trackable_values(test_data[2], [3, 'DE'])
      expect(test_data.last).to eq('|')
    end
  end
end
