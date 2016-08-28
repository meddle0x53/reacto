context Reacto::Trackable do
  subject(:source) { described_class.enumerable(%w(albatross dog horse snake)) }

  context '#min_by' do
    it 'emits the value emitted by source that gives the minimum value from ' \
      'the given block. ' do
      attach_test_trackers(source.min_by { |val| val.size })

      expect(test_data).to eq(%w(dog |))
    end
  end
end
