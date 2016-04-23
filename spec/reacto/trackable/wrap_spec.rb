require 'spec_helper'

context Reacto::Trackable do
  context '#wrap' do
    it 'wraps the incomming value in object with field `value` - the value' \
      ' and the specified fields' do
      now = Time.now
      trackable = described_class.enumerable([1, 2]).wrap(now: now)

      trackable.on(value: test_on_value)

      expect(test_data.size).to be 2
      expect(test_data.first.value).to be 1
      expect(test_data.first.now).to be now
      expect(test_data.last.value).to be 2
      expect(test_data.last.now).to be now
    end

    it 'wraps the incomming value in object with field `value` - the value' \
      ' and the specified fields if some of the field values are lambdas, ' \
      'they are called with passed parameter - the incoming value' do
      now = Time.now
      trackable = described_class.enumerable([1, 2]).wrap(
        now: now, bau: ->(v) { v * 2 }
      )

      trackable.on(value: test_on_value)

      expect(test_data.size).to be 2
      expect(test_data.first.value).to be 1
      expect(test_data.first.now).to be now
      expect(test_data.first.bau).to be 2
      expect(test_data.last.value).to be 2
      expect(test_data.last.now).to be now
      expect(test_data.last.bau).to be 4
    end

    it 'raises an ArgumentError if the hash passed has a `value` key' do
      expect { described_class.enumerable([1, 2]).wrap(value: 4) }.to(
        raise_error(ArgumentError).with_message(
          "'value' is not valid key in the wrapping object"
        )
      )
    end
  end
end
