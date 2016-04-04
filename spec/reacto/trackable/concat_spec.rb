require 'spec_helper'

context Reacto::Trackable do
  context '#concat' do
    it 'starts emitting the values from the concatenated after emitting the ' \
      'values from the source, then emits a `close` notification' do
      trackable = source.concat(described_class.enumerable((6..10)))
      trackable.on(value: test_on_value, close: test_on_close)

      expect(test_data).to be == (5..10).to_a + ['|']
    end

    it 'can be chained' do
      trackable = source
      .concat(described_class.enumerable((6..8)))
      .concat(described_class.enumerable((9..10)))
      trackable.on(value: test_on_value, close: test_on_close)

      expect(test_data).to be == (5..10).to_a + ['|']
    end

    it 'closes on error' do
      err = StandardError.new('Hey')
      trackable = source
      .concat(described_class.error(err))
      .concat(described_class.enumerable((9..10)))
      trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )

      expect(test_data).to be == [5, err]
    end
  end
end
