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

    context 'with label' do
      it 'applies the transformation passed only to the values of ' \
        'the incoming values of type LabeledTrackable with matching label' do
        trackable =
          Reacto::Trackable.enumerable((1..10).each).group_by_label do |value|
            [(value % 3), value]
          end

        trackable = trackable.flat_map(label: 1) do |value|
          Reacto::Trackable.enumerable((value..10))
        end

        trackable.on(value: test_on_value)

        labeled_trackable = test_data.first
        expect(labeled_trackable.label).to eq(1)

        labeled_data = []
        labeled_trackable.on(value: ->(v) { labeled_data << v })

        expected = [(1..10), (4..10), (7..10)].map(&:to_a).flatten + [10]
        expect(labeled_data).to eq(expected)
      end
    end
  end
end
