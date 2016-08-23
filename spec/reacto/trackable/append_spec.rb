context Reacto::Trackable do
  context '#append' do
    it 'emits a given enumerable after all the values, incoming from the ' \
      'caller are emitted' do
      source = described_class.enumerable((1..5))
      trackable = source.append((6..10))

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(10)
      expect(test_data).to eq((1..10).to_a)
    end

    it 'does not append anything if `condition: :source_empty` is given ' \
      'and the source has emitted values' do
      source = described_class.enumerable((1..5))
      trackable = source.append((6..10), condition: :source_empty)

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(5)
      expect(test_data).to eq((1..5).to_a)
    end

    it 'emits a given enumerable after the `close` notification, incoming ' \
      'from the caller is emitted if `condition: :source_empty` is given and ' \
      'no values were emitted' do
      source = described_class.close
      trackable = source.append((6..10), condition: :source_empty)

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(5)
      expect(test_data).to eq((6..10).to_a)
    end
  end
end

