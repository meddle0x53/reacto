context Reacto::Trackable do
  context '#each_with_object' do
    subject(:test_source) do
      lyrics = 'I am drinking I am rolling I am hiding I am running'
      described_class.enumerable(lyrics.split(''))
    end

    it 'calls the given block for each value emitted by the source ' \
      'with an arbitrary object given, and emits the initially given object' do
      trackable = test_source.each_with_object({}) do |v, memo|
        unless v.strip.empty?
          memo[v] ||= 0
          memo[v] += 1
        end
      end
      attach_test_trackers(trackable)

      expect(test_data.size).to eq(2)
      expect(test_data.first).to eq({
        'I' => 4, 'a' => 4, 'm' => 4, 'd' => 2, 'r' => 3, 'i' => 6, 'n' => 7,
        'k' => 1, 'g' => 4, 'o' => 1, 'l' => 2, 'h' => 1, 'u' => 1
      })
    end
  end
end
