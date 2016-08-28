context Reacto::Trackable do
  context '#each_with_index' do
    subject(:test_source) { described_class.enumerable(('A'..'F')) }

    it 'calls the given block with two arguments, the value and its index, ' \
      'for each emitted value' do

      test_source.each_with_index { |v, i| test_data << [v, i] }

      expect(test_data).to eq([
        ['A', 0], ['B', 1], ['C', 2], ['D', 3], ['E', 4], ['F', 5]
      ])
    end

    it 'returns a Reacto::Subscription' do
      subscription = test_source.each_with_index { |v, i| test_data << [v, i] }

      expect(subscription).to_not be(nil)
      expect(subscription).to be_kind_of(Reacto::Subscriptions::Subscription)
    end

    it 'returns a new Trackable with the each_with_index behavior ' \
      'if no block was given' do
      trackable = test_source.each_with_index

      attach_test_trackers(trackable)

      expect(test_data).to eq([
        ['A', 0], ['B', 1], ['C', 2], ['D', 3], ['E', 4], ['F', 5], '|'
      ])
    end
  end
end
