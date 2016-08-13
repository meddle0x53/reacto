context Reacto::Trackable do
  context '#chunk' do
    def expect_values(trackable, label, expected)
      expect_trackable_values(trackable, expected, label: label)
    end

    let(:data) { [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5] }
    subject { described_class.enumerable(data) }

    it 'creates a Reacto::Trackable which chunks the incoming values ' \
      'together based on the return value of the given block. ' \
      'The chuncks are emitted as LabeledTrackable instances' do
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

    it 'uses nil as flag to group items' \
      'together based on the return value of the given block. ' \
      'The chuncks are emitted as LabeledTrackable instances' do
      trackable = subject.chunk { |v| v.even? ? 'even' : nil }

      attach_test_trackers(trackable)

      expect(test_data.length).to be(3)
      expect_values(test_data.first, 'even', [4])
      expect_values(test_data[1], 'even', [2, 6])
      expect(test_data.last).to eq('|')
    end

    it 'uses :_separator as flag to group items' \
      'together based on the return value of the given block. ' \
      'The chuncks are emitted as LabeledTrackable instances' do
      trackable = subject.chunk { |v| v.even? ? :_separator : 'odd' }

      attach_test_trackers(trackable)

      expect(test_data.length).to be(4)
      expect_values(test_data.first, 'odd', [3, 1])
      expect_values(test_data[1], 'odd', [1, 5, 9])
      expect_values(test_data[2], 'odd', [5, 3, 5])
      expect(test_data.last).to eq('|')
    end

    it 'uses :_alone as flag to emit a LabeledTrackable which emits only one ' \
      'value, the one marked as :_alone' do
      trackable = subject.chunk do |v|
        v.even? ? :_alone : 'odd'
      end

      attach_test_trackers(trackable)

      expect(test_data.length).to be(7)
      expect_values(test_data.first, 'odd', [3, 1])
      expect_values(test_data[1], :_alone, [4])
      expect_values(test_data[2], 'odd', [1, 5, 9])
      expect_values(test_data[3], :_alone, [2])
      expect_values(test_data[4], :_alone, [6])
      expect_values(test_data[5], 'odd', [5, 3, 5])
      expect(test_data.last).to eq('|')
    end

    it 'emits an error if the label returned by the ckunking function is a ' \
      'symbol, which starts with `_` and it is not :_separator or :_alone' do
      trackable = subject.chunk do |v|
        v.even? ? :_stuff : 'odd'
      end

      attach_test_trackers(trackable)

      expect(test_data.length).to be(2)
      expect_values(test_data.first, 'odd', [3, 1])
      expect(test_data.last).to eq(RuntimeError.new(
        'symbols beginning with an underscore are reserved'
      ))
    end
  end
end
