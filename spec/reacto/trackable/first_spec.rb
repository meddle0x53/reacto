context Reacto::Trackable do
  context '#first' do
    subject(:test_source) { described_class.enumerable((1..100)) }

    it 'emits only the first element emitted by the source' do
      trackable = test_source.first

      attach_test_trackers(trackable)

      expect(test_data).to eq([1, '|'])
    end

    it 'emits only the first <n> element emitted by the source ' \
      'if <n> is given' do
      trackable = test_source.first(5)

      attach_test_trackers(trackable)

      expect(test_data).to eq([1, 2, 3, 4, 5, '|'])
    end

    it 'raises an ArgumentError if <n> is given and is bellow zero' do
      expect do
        test_data.first(-2)
      end.to raise_error(ArgumentError).with_message('negative array size')
    end

    it 'emits only the close notification if <n> is given and is zero' do
      trackable = test_source.first(0)

      attach_test_trackers(trackable)

      expect(test_data).to eq(['|'])
    end
  end
end
