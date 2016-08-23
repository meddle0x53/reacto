context Reacto::Trackable do
  context '#include?' do
    subject(:test_source) { described_class.enumerable((1..10)) }

    it 'it creates a Reacto::Trackable emitting only one value : `true` if ' \
      'the object given is emitted by the source' do
      trackable = test_source.include?(5)

      attach_test_trackers(trackable)

      expect(test_data).to eq([true, '|'])
    end

    it 'it creates a Reacto::Trackable emitting only one value : `false` if ' \
      'the object given is not emitted by the source' do
      trackable = test_source.include?(15)

      attach_test_trackers(trackable)

      expect(test_data).to eq([false, '|'])
    end
  end
end
