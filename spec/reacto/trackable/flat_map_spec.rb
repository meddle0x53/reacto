require 'spec_helper'

context Reacto::Trackable do
  context 'flat_map' do
    it 'flattens the notification of the Trackable objects produced by ' \
      'the passed transformation function and turns them to one stream of ' \
      'notifications' do
      trackable = described_class.enumerable((1..5)).flat_map do |val|
        Reacto::Trackable.enumerable([val, val + 1])
      end

      trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )
      expect(test_data).to be == [1, 2, 2, 3, 3, 4, 4, 5, 5, 6, '|']
    end
  end
end

