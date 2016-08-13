context Reacto::Trackable do
  context '#chunk_while' do

    let(:data) { [1, 2, 4, 9, 10, 11, 12, 15, 16, 19, 20, 21] }
    subject(:source_trackable) { described_class.enumerable(data) }

    it 'emits a Trackable for each chunked values. ' \
      'The beginnings of chunks are defined by the block.' do
      trackable = source_trackable.chunk_while { |i, j| i + 1 == j }

      attach_test_trackers(trackable)

      expect(test_data.length).to be(6)
      expect_trackable_values(test_data.first, [1, 2])
      expect_trackable_values(test_data[1], [4])
      expect_trackable_values(test_data[2], [9, 10, 11, 12])
      expect_trackable_values(test_data[3], [15, 16])
      expect_trackable_values(test_data[4], [19, 20, 21])
      expect(test_data.last).to eq('|')
    end
  end
end
