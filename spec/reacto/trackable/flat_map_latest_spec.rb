require 'spec_helper'

context Reacto::Trackable do
  context 'flat_map_latest' do
    it 'TODO' do
      trackable = described_class.interval(1).take(3).flat_map_latest do |val|
        Reacto::Trackable.interval(0.3, (val..7).to_enum)
      end

      subscription = trackable.on(
        value: test_on_value, close: test_on_close, error: test_on_error
      )

      trackable.await(subscription)
      expect(test_data).to be == [0, 1, 2, 1, 2, 3, 2, 3, 4, 5, 6, 7, '|']
    end
  end
end
