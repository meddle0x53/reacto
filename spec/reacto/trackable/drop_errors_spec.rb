require 'spec_helper'

context Reacto::Trackable do
  context '#drop_errors' do
    it 'drops all the errors from the source and continues' do
      described_class.enumerable((1..5)).concat(
        described_class.error(StandardError.new)
      ).concat(described_class.enumerable(6..10)).drop_errors.on(
        value: test_on_value, error: test_on_error, close: test_on_close
      )

      expect(test_data).to be == (1..10).to_a + ['|']
    end
  end
end
