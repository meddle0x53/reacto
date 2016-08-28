context Reacto::Trackable do
  subject(:source) { described_class.enumerable(%w(albatross dog horse snake)) }

  context '#minmax' do
    it 'emits the minimum and then the maximum values emitted by source ' \
      'assuming that all the values implement Comparable' do
      attach_test_trackers(source.minmax)

      expect(test_data).to eq(%w(albatross snake |))
    end

    it 'emits the maximum and then the maximum values emitted by source ' \
      'using the block given to compare the values ' do
      attach_test_trackers(source.minmax { |v1, v2| v1.size <=> v2.size })

      expect(test_data).to eq(%w(dog albatross |))
    end
  end
end
