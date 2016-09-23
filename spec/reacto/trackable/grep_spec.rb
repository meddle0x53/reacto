context Reacto::Trackable do
  context '#grep' do
    subject(:test_source) { described_class.enumerable((1..100)) }

    it 'returns a Reacto::Trackable emitting every value emitted by the ' \
      'source for which the given <pattern> === value' do
      trackable = test_source.grep(38..44)

      attach_test_trackers(trackable)

      expect(test_data).to eq([38, 39, 40, 41, 42, 43, 44, '|'])
    end

    subject(:test_source2) do
      described_class.enumerable(%w(
        HEY FIND_ME YO FIND_HER FIND_IT FOUND_ME NO_WAY
      ))
    end

    it 'passes each matching value to the optional block, if supplied and ' \
      'the reuslts from it are emitted' do
      trackable = test_source2.grep(/FIND/) { |v| v[-1] }

      attach_test_trackers(trackable)

      expect(test_data).to eq(%w(E R T |))
    end
  end
end
