context Reacto::Trackable do
  subject(:source) { described_class.enumerable(%w(a b c)) }

  context '#cycle' do
    it 'emits all the elements of the source repeatedly the given `n` times ' do
      trackable = source.cycle(3)

      attach_test_trackers(trackable)

      expect(test_data.size).to eq(10)
      expect(test_data).to eq((%w(a b c) * 3) + %w(|))
    end
  end
end
