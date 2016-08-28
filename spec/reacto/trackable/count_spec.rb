context Reacto::Trackable do
  subject(:source) { described_class.enumerable([1, 2, 4, 2]) }

  context '#count' do
    it 'returns a Trackable, emitting only one value - the number of values ' \
      'emitted by the caller of this operation' do
      counting_trackable = source.count

      attach_test_trackers(counting_trackable)

      expect(test_data.size).to be 2
      expect(test_data.first).to eq(4)
      expect(test_data.last).to eq('|')
    end

    it 'returns a Trackable, emitting only one value - the number of values, ' \
      'equal to the given as argument one, if such is given' do
      counting_trackable = source.count(2)

      attach_test_trackers(counting_trackable)

      expect(test_data.size).to be 2
      expect(test_data.first).to eq(2)
      expect(test_data.last).to eq('|')
    end

    it 'returns a Trackable, emitting only one value - the number of values, ' \
      'yielding a true value if a block is given' do
      counting_trackable = source.count { |v| v.even? }

      attach_test_trackers(counting_trackable)

      expect(test_data.size).to be 2
      expect(test_data.first).to eq(3)
      expect(test_data.last).to eq('|')
    end
  end
end
