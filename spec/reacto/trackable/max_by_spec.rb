context Reacto::Trackable do
  subject(:source) { described_class.enumerable(%w(albatross dog horse snake)) }

  context '#max_by' do
    it 'emits the value emitted by source that gives the maximum value from ' \
      'the given block. ' do
      attach_test_trackers(source.max_by(&:size))

      expect(test_data).to eq(%w(albatross |))
    end
  end
end
