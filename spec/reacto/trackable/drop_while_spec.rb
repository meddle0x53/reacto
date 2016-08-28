context Reacto::Trackable do
  context '#drop_while' do
    it 'drops elements up to, but not including, the first element for which ' \
      'the block returns nil or false' do
      trackable = described_class.enumerable((1..5)).drop_while do |val|
        val < 4
      end

      attach_test_trackers(trackable)

      expect(test_data.size).to be(3)
      expect(test_data).to eq([4, 5, '|'])
    end
  end
end
