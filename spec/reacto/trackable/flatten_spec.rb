require 'spec_helper'

context Reacto::Trackable do
  context 'flatten' do
    it 'sends the members of array values as values' do
      trackable =
        described_class.enumerable([[1, 2, 3], [4, 3], [2, 1, 5]]).flatten

      trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )
      expect(test_data).to be == [1, 2, 3, 4, 3, 2, 1, 5, '|']
    end
  end
end
