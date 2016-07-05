require 'spec_helper'

context Reacto::Trackable do
  context '#diff' do
    it 'by default emits arrays with two values the - previous and current ' \
      'element' do
      source = described_class.enumerable((1..10))
      trackable = source.diff
      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data).to be == [
        [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10
      ]]
    end

    it 'can be passed a diff function to calculate the difference between ' \
      'the previously emitted value and the current and to emit it' do
      source = described_class.enumerable((1..10))
      trackable = source.diff(Reacto::NO_VALUE) { |p, c|  c - p }
      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data).to be == [1] * 9
    end

    it 'can be passed a diff block to calculate the difference between ' \
      'the previously emitted value and the current and to emit it' do
      source = described_class.enumerable((1..10))
      trackable = source.diff { |p, c| c - p }
      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data).to be == [1] * 9
    end

    it 'can receive initial value to be used as seed - the first value' do
      source = described_class.enumerable((1..10))
      trackable = source.diff(-5) { |p, c| c - p }
      trackable.on(value: test_on_value, error: test_on_error)

      expect(test_data).to be == [6] + ([1] * 9)
    end
  end
end
