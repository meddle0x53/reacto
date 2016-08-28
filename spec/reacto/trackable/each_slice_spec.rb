context Reacto::Trackable do
  context '#each_slice' do
    subject(:test_source) { described_class.enumerable((1..10)) }

    it 'raises an ArgumentError if the size given as first argument '\
      'is zero or smaller' do
      expect do
        test_source.each_slice(-1) { |v| p v }
      end.to raise_error(ArgumentError).with_message('invalid size')
    end

    it 'calls the given block for each slice of <n> emitted values' do
      test_data = []
      test_source.each_slice(3) { |v| test_data << v }

      expect(test_data).to eq([[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]])
    end

    it 'returns a Reacto::Subscription' do
      subscription = test_source.each_slice(3) { |v| test_data << v }

      expect(subscription).to_not be(nil)
      expect(subscription).to be_kind_of(Reacto::Subscriptions::Subscription)
    end

    it 'returns a new Trackable with the each_slice behavior ' \
      'if no block was given' do
      trackable = test_source.each_slice(1)

      attach_test_trackers(trackable)

      expect(test_data).to eq([
        [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], '|'
      ])
    end
  end
end
