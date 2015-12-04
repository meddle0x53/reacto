require 'spec_helper'

context Reacto::Trackable do

  let(:test_data) { [] }
  let(:test_on_value) { -> (v) { test_data << v }}
  let(:test_on_close) { -> () { test_data << '|' }}
  let(:test_on_error) { -> (e) { test_data << e }}

  def attach_test_trackers(trackable)
    trackable.on(
      value: test_on_value,
      error: test_on_error,
      close: test_on_close
    )
  end

  context '.never' do
    it 'creates a new trackable, which won\'t send any notifications' do
      attach_test_trackers described_class.never

      expect(test_data).to be_empty
    end
  end

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

  context '.timeout' do
    it 'emits the passed value after the passed time runs out and then emits ' \
      'a close notification' do
      trackable = described_class.timeout(0.2, 5)
      subscription = attach_test_trackers(trackable)

      expect(test_data).to be_empty
      trackable.await(subscription)
      expect(test_data).to be == [5, '|']
    end

    it 'it can use a specific executor' do
      trackable = described_class.timeout(0.2, 5, Reacto::Executors.immediate)
      subscription = attach_test_trackers(trackable)
      expect(test_data).to be == [5, '|']
    end
  end
end
