context Reacto::Trackable do
  context '#merge' do
    it 'merges the passed trackable\'s emitions with the source ones' do
      trackable =
        described_class.interval(0.2).map { |v| v.to_s + 'a'}.take(5)
      to_be_merged =
        described_class.interval(0.35).map { |v| v.to_s + 'b'}.take(4)
      subscription = trackable.merge(to_be_merged).on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )
      trackable.await(subscription)

      expect(test_data).to eq(
        ['0a', '0b', '1a', '2a', '1b', '3a', '4a', '2b', '3b', '|']
      )
    end

    it 'finishes with the error if `delay_error` is true' do
      err = StandardError.new('Hey')
      trackable = described_class.interval(0.2).map do |v|
        raise err if v == 3
        v.to_s + 'a'
      end.take(5)

      to_be_merged =
        described_class.interval(0.35).map { |v| v.to_s + 'b'}.take(4)

      trackable = trackable.merge(to_be_merged, delay_error: true)
      subscription = trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )
      trackable.await(subscription, 2)

      expect(test_data).to eq(
        ['0a', '0b', '1a', '2a', '1b', '2b', '3b', err]
      )
    end
  end
end
