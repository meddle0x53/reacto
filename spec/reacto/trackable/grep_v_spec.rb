context Reacto::Trackable do
  context '#grep_v' do
    subject(:test_source) { described_class.enumerable((1..10)) }

    it 'returns a Reacto::Trackable emitting every value emitted by the ' \
      'source for which the given <pattern> === value returns false' do
      trackable = test_source.grep_v(2..5)

      attach_test_trackers(trackable)

      expect(test_data).to eq([1, 6, 7, 8, 9, 10, '|'])
    end

    it 'passes each not matching value to the optional block, if supplied ' \
      'and the reuslts from it are emitted' do
      trackable = test_source.grep_v(2..7) { |v| v.even? }

      attach_test_trackers(trackable)

      expect(test_data).to eq([false, true, false, true, '|'])
    end
  end
end
