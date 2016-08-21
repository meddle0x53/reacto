context Reacto::Trackable do
  subject(:test_source) { described_class.enumerable(('a'..'z')) }

  context '#find_index' do
    it 'passes each emitted value from the source to block. Emits the ' \
      'index of the first for which the evaluated value is non-false. ' do
      trackable = test_source.find_index { |val| val == 'i' || val == 'h' }

      attach_test_trackers(trackable)

      expect(test_data).to eq([7, '|'])
    end

    it 'compares each emitted value with the given value, if such is given. ' \
      'Emits the index of the first which is equal to the value, given.' do
      trackable = test_source.find_index('j')

      attach_test_trackers(trackable)

      expect(test_data).to eq([9, '|'])
    end

    it 'emits only the close notification if there is no match' do
      trackable = test_source.find_index('A')

      attach_test_trackers(trackable)

      expect(test_data).to eq(['|'])
    end
  end
end
