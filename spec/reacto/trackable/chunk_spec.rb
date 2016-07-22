context Reacto::Trackable do
  context '#chunk' do
    def expect_values(trackable, label, expected)
      expect(trackable.label).to eq(label)

      values = []
      trackable.on { |v| values << v }
      expect(values).to eq(expected)
    end

    let(:data) { [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5] }
    subject { described_class.enumerable(data) }

    it 'creates a Reacto::Trackable which chunks the incoming values ' \
      'together based on the return value of the given block. ' \
      'The chunck are emitted as LabeledTrackable instances' do
      trackable = subject.chunk { |v| v.even? }

      attach_test_trackers(trackable)

      expect(test_data.length).to be(6)
      expect_values(test_data.first, false, [3, 1])
      expect_values(test_data[1], true, [4])
      expect_values(test_data[2], false, [1, 5, 9])
      expect_values(test_data[3], true, [2, 6])
      expect_values(test_data[4], false, [5, 3, 5])
      expect(test_data.last).to eq('|')
    end

    it 'uses nil as flag to drop items' \
      'together based on the return value of the given block. ' \
      'The chunck are emitted as LabeledTrackable instances' do
      trackable = subject.chunk { |v| v.even? ? 'even' : nil }

      attach_test_trackers(trackable)

      expect(test_data.length).to be(3)
      expect_values(test_data.first, 'even', [4])
      expect_values(test_data[1], 'even', [2, 6])
      expect(test_data.last).to eq('|')
    end

    it 'uses :_separator as flag to drop items' \
      'together based on the return value of the given block. ' \
      'The chunck are emitted as LabeledTrackable instances' do
      trackable = subject.chunk { |v| v.even? ? :_separator : 'odd' }

      attach_test_trackers(trackable)

      expect(test_data.length).to be(4)
      expect_values(test_data.first, 'odd', [3, 1])
      expect_values(test_data[1], 'odd', [1, 5, 9])
      expect_values(test_data[2], 'odd', [5, 3, 5])
      expect(test_data.last).to eq('|')
    end
  end
end
