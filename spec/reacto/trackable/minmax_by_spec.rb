context Reacto::Trackable do
  subject(:source) { described_class.enumerable(%w(albatross dog horse snake)) }

  context '#minmax_by' do
    it 'emits the values emitted by source that give the minimum value and ' \
      'the maximum value from the given block. ' do
      attach_test_trackers(source.minmax_by { |val| val.size })

      expect(test_data).to eq(%w(dog albatross |))
    end
  end
end
