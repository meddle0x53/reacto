context Reacto::Trackable do
  context '#take_while' do
    subject(:test_source) do
      described_class.enumerable(%w(some stuff hey way okay refrigerator bat))
    end

    it 'returns a Reacto::Trackable emitting the values incomming from the' \
      ' source, until the block given returns false' do
      trackable = test_source.take_while { |val| val.length < 6 }

      attach_test_trackers(trackable)

      expect(test_data).to eq(%w(some stuff hey way okay |))
    end
  end
end
