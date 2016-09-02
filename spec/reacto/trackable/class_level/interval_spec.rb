context Reacto::Trackable do
  context '.interval' do
    it 'emits an infinite sequence of number on every n seconds by default' do
      trackable = described_class.interval(0.3)
      subscription = attach_test_trackers(trackable)
      sleep 1
      subscription.unsubscribe

      expect(test_data).to eq((0..2).to_a)
    end

    it 'can use any enumerator to produce the sequence to emit' do
      trackable = described_class.interval(0.1, ('a'..'z').each)
      subscription = attach_test_trackers(trackable)
      sleep 1
      subscription.unsubscribe

      expect(test_data).to include(*('a'..'i').to_a)
    end

    it 'handles interval of intervals' do
      trackable = described_class.interval(0.5, (5..5).each)
        .map { |v| v * 2 }
        .flat_map { |v| Reacto::Trackable.interval(0.1, (v..15).each) }
      subscription = attach_test_trackers(trackable)

      trackable.await(subscription)

      expect(test_data).to eq((10..15).to_a + ['|'])
    end

    it 'can use the immediate executor to block the current thread while ' \
      'emitting' do
      trackable = described_class.interval(
        0.1, (1..5).each, executor: Reacto::Executors.immediate
      )
      attach_test_trackers(trackable)

      expect(test_data).to eq((1..5).to_a + ['|'])
    end
  end
end
