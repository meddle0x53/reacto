context Reacto::Trackable do
  context '#each_cons' do
    subject(:test_source) { described_class.enumerable((1..10)) }

    it 'raises an ArgumentError if the size given as first argument '\
      'is zero or smaller' do
      expect do
        test_source.each_cons(0) do |v|
          p v
        end
      end.to raise_error(ArgumentError).with_message('invalid size')
    end

    it 'behaves as #each/#on if the size given is 1' do
      test_data = []
      test_source.each_cons(1) { |v| test_data << v }

      expect(test_data).to eq((1..10).to_a)
    end

    it 'calls the given block for each array of consecutive <n> emitted ' \
      'values' do
      test_data = []
      test_source.each_cons(2) { |v| test_data << v }

      expect(test_data).to eq(
        [
          [1, 2], [2, 3], [3, 4], [4, 5], [5, 6],
          [6, 7], [7, 8], [8, 9], [9, 10]
        ]
      )
    end

    it 'returns a Reacto::Subscription' do
      subscription = test_source.each_cons(3) { |v| test_data << v }

      expect(subscription).to_not be(nil)
      expect(subscription).to be_kind_of(Reacto::Subscriptions::Subscription)
    end

    it 'returns a new Trackable with the each_cons behavior ' \
      'if no block was given' do
      trackable = test_source.each_cons(4)

      attach_test_trackers(trackable)

      expect(test_data).to eq([
        [1, 2, 3, 4], [2, 3, 4, 5], [3, 4, 5, 6], [4, 5, 6, 7], [5, 6, 7, 8],
        [6, 7, 8, 9], [7, 8, 9, 10], '|'
      ])
    end
  end
end
