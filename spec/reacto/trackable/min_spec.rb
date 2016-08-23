context Reacto::Trackable do
  subject(:source) { described_class.enumerable(%w(albatross dog horse snake)) }

  context '#min' do
    it 'emits the minimum value emitted by source assuming that all the ' \
      'values implement Comparable' do
      attach_test_trackers(source.min)

      expect(test_data).to eq(%w(albatross |))
    end

    it 'emits the minimum value emitted by source using the block given to ' \
      'compare the values ' do
      attach_test_trackers(source.min { |val1, val2| val1.size <=> val2.size })

      expect(test_data).to eq(%w(dog |))
    end
  end
end
