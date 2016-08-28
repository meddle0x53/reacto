context Reacto::Trackable do
  context '#slice_when' do
    subject(:test_source) do
      described_class.enumerable([1, 2, 3, 100, 101, 102, 5, 200, 500, 7, 8])
    end

    it 'emits Reacto::Trackable instances emitting slices of the values, ' \
      'emitted by the source. The slices are determined by the current and ' \
      'the previous values for which the block given returns true' do
      trackable = test_source.slice_when do |previous, current|
        (current - previous).abs > 20
      end

      attach_test_trackers(trackable)

      expect(test_data.size).to eq(7)
      expect_trackable_values(test_data.first, [1, 2, 3])
      expect_trackable_values(test_data[1], [100, 101, 102])
      expect_trackable_values(test_data[2], [5])
      expect_trackable_values(test_data[3], [200])
      expect_trackable_values(test_data[4], [500])
      expect_trackable_values(test_data[5], [7, 8])
      expect(test_data.last).to eq('|')
    end
  end
end
