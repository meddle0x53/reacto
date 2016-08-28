context Reacto::Trackable do
  context '.combine_last' do
    it 'combines the notifications of Trackables based on their ' \
      'sequence number - the first notifications of the sources, then ' \
      'the next ones and in the end closes if any of the sources closes' do
      trackable1 = described_class.interval(0.3).take(4)
      trackable2 = described_class.interval(0.7, ('a'..'b').each)
      trackable3 = described_class.interval(0.5, ('A'..'C').each)

      trackable = described_class.combine_last(
        trackable1, trackable2, trackable3
      ) do |v1, v2, v3|
        "#{v1} : #{v2} : #{v3}"
      end

      subscription = attach_test_trackers(trackable)
      trackable.await(subscription)

      expect(test_data).to be == [
        '1 : a : A', '3 : b : B', '|'
      ]
    end
  end
end
