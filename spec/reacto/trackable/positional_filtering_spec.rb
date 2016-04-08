require 'spec_helper'

context Reacto::Trackable do
  context '#drop, #take, #last, #first, #[]' do
    let(:test_behaviour) do
      lambda do |tracker_subscription|
        (1..15).each do |value|
          tracker_subscription.on_value(value)
        end

        tracker_subscription.on_close
      end
    end

    context('#drop') do
      it 'drops the first `n` values sent by the source' do
        source.drop(6).on(value: test_on_value)

        expect(test_data.size).to be(9)
        expect(test_data).to be == (7..15).to_a
      end
    end

    context('#take') do
      it 'sents only the first `n` values sent by the source' do
        source.take(6).on(value: test_on_value)

        expect(test_data.size).to be(6)
        expect(test_data).to be == (1..6).to_a
      end
    end

    context('#last') do
      it 'emits only the last value of the source and the closing ' \
        'notification' do
        source.last.on(value: test_on_value, close: test_on_close)

        expect(test_data).to be == [15, '|']
      end

      it 'only closes if no value was emitted by the source' do
        described_class.close.last.on(
          value: test_on_value, close: test_on_close
        )

        expect(test_data).to be == ['|']
      end

      it 'emits the last value before the error and the error when error ' \
        'notification is received from the source' do
        err = StandardError.new('Hey!')
        source.concat(described_class.error(err)).last.on(
          value: test_on_value, close: test_on_close, error: test_on_error
        )

        expect(test_data).to be == [15, err]
      end
    end

    context('#first') do
      it 'emits only the first value of the source and closes' do
        source.first.on(
          value: test_on_value, close: test_on_close
        )

        expect(test_data).to be == [1, '|']
      end

      it 'only closes if no value was emitted by the source' do
        described_class.close.first.on(
          value: test_on_value, close: test_on_close
        )

        expect(test_data).to be == ['|']
      end
    end

    context('#[]') do
      it 'emits only the n-th value of the source and closes' do
        source[4].on(
          value: test_on_value, close: test_on_close
        )

        expect(test_data).to be == [5, '|']
      end

      it 'just closes if no value was emitted by the source' do
        described_class.close[3].on(
          value: test_on_value, close: test_on_close
        )

        expect(test_data).to be == ['|']
      end
    end
  end
end
