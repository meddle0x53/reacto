require 'spec_helper'

context Reacto::Trackable do
  context '.make' do
    it 'creates a new trackable with custom behaviour passed as lambda' do
      behaviour = lambda do |tracker|
        (1..10).each do |v|
          tracker.on_value(v)
        end

        tracker.on_close
      end

      attach_test_trackers described_class.make(behaviour)

      expect(test_data.size).to be(11)
      expect(test_data).to be == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, '|']
    end

    it 'creates a new trackable with custom behaviour passed as block' do
      trackable = described_class.make do |tracker|
        (1..10).each do |v|
          tracker.on_value(v)
        end

        tracker.on_close
      end
      attach_test_trackers trackable

      expect(test_data.size).to be(11)
      expect(test_data).to be == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, '|']
    end

    it 'does not emit anything once it is closed' do
      trackable = described_class.make do |tracker|
        (1..5).each do |v|
          tracker.on_value(v)
        end

        tracker.on_close

        (1..5).each do |v|
          tracker.on_value(v)
        end
      end
      attach_test_trackers trackable

      expect(test_data.size).to be(6)
      expect(test_data).to be == [1, 2, 3, 4, 5, '|']
    end

    it 'does not emit anything once it has an error' do
      trackable = described_class.make do |tracker|
        (1..5).each do |v|
          tracker.on_value(v)
        end

        tracker.on_error('error')

        (1..5).each do |v|
          tracker.on_value(v)
        end
      end
      attach_test_trackers trackable

      expect(test_data.size).to be(6)
      expect(test_data).to be == [1, 2, 3, 4, 5, 'error']
    end

    it 'emits the same behaviour for every subscribe' do
      trackable = described_class.make do |tracker|
        (1..5).each do |v|
          tracker.on_value(v)
        end

        tracker.on_close
      end
      attach_test_trackers trackable
      attach_test_trackers trackable

      expect(test_data.size).to be(12)
      expect(test_data).to be == [1, 2, 3, 4, 5, '|', 1, 2, 3, 4, 5, '|']
    end
  end
end
