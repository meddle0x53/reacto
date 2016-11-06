context Reacto::Trackable do
  context '#partition' do
    def expect_values(trackable, label, expected)
      expect_trackable_values(trackable, expected, label: label)
    end

    let(:data) { [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5] }
    subject(:test_source) { described_class.enumerable(data) }

    it 'creates a Reacto::Trackable which emits two LabeledTrackable ' \
      'instances, the first with label `true`, emitting values for which' \
      'the given block evaluates to true, the second emitting the rest' do
      trackable = test_source.partition(&:even?)

      attach_test_trackers(trackable)

      expect(test_data.length).to be(3)
      expect_values(test_data.first, true, [4, 2, 6])
      expect_values(test_data[1], false, [3, 1, 1, 5, 9, 5, 3, 5])
      expect(test_data.last).to eq('|')
    end
  end
end
