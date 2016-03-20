require 'spec_helper'

context Reacto::Trackable do
  context '#buffer' do
    context 'count' do
      it 'sends values on batches with the size of the passed count' do
        trackable = described_class.enumerable((1..20)).buffer(count: 5)
        trackable.on(
          value: test_on_value, close: test_on_close, error: test_on_error
        )

        expect(test_data).to be ==
          [(1..5).to_a, (6..10).to_a, (11..15).to_a, (16..20).to_a, '|']
      end
    end

    context 'delay' do
      it 'sends values on batches on intervals - the passed delay' do
        trackable = described_class.interval(0.1).take(20).buffer(delay: 0.5)
        subscription = trackable.on(
          value: test_on_value, close: test_on_close, error: test_on_error
        )
        trackable.await(subscription)
        expect(test_data).to be ==
          [
            [0, 1, 2, 3],
            [4, 5, 6, 7, 8],
            [9, 10, 11, 12, 13],
            [14, 15, 16, 17, 18],
            [19],
            "|"
        ]
      end
    end

    context 'count & delay' do
      it 'uses either the count or the delay to buffer and send' do
        trackable = described_class.make do |subscriber|
          subscriber.on_value(1)
          subscriber.on_value(2)
          subscriber.on_value(3)
          subscriber.on_value(4)
          subscriber.on_value(5)
          sleep 1
          subscriber.on_value(6)
          subscriber.on_close
        end.buffer(delay: 0.5, count: 3)

        trackable.on(
          value: test_on_value, close: test_on_close, error: test_on_error
        )
        expect(test_data).to be ==
          [[1, 2, 3], [4, 5], [6], '|']
      end
    end
  end
end

