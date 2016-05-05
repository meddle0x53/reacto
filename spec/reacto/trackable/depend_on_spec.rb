require 'spec_helper'

context Reacto::Trackable do
  context '#depend_on' do
    it 'suspends its caller untill the passed Trackable emits its ' \
      'notifications and wraps the value of the caller with the accumulated ' \
      'data of these notifications' do
      trackable = described_class.enumerable([1, 5, 4]).depend_on(
        described_class.value(10)
      )

      attach_test_trackers(trackable)

      expect(test_data.size).to be 4
      expect(test_data[0].value).to be 1
      expect(test_data[0].data).to be 10
      expect(test_data[1].value).to be 5
      expect(test_data[1].data).to be 10
      expect(test_data[2].value).to be 4
      expect(test_data[2].data).to be 10
      expect(test_data.last).to be == '|'
    end

    it 'it uses the first emitted value for the data from the dependency ' \
      'if no accumulator lambda/block is passed.' do
      trackable = described_class.enumerable([1, 5, 4]).depend_on(
        described_class.interval(0.4, [5, 10].each)
      )

      subscription = attach_test_trackers(trackable)
      trackable.await(subscription)

      expect(test_data.size).to be 4
      expect(test_data[0].value).to be 1
      expect(test_data[0].data).to be 5
      expect(test_data[1].value).to be 5
      expect(test_data[1].data).to be 5
      expect(test_data[2].value).to be 4
      expect(test_data[2].data).to be 5
      expect(test_data.last).to be == '|'
    end

    it 'uses the block passed to accumulate the dependency data' do
      trackable = described_class.enumerable([5, 4]).depend_on(
        described_class.enumerable((1..10))
      ) { |prev, v| prev + v }

      attach_test_trackers(trackable)

      expect(test_data.size).to be 3
      expect(test_data[0].value).to be 5
      expect(test_data[0].data).to be 55
      expect(test_data[1].value).to be 4
      expect(test_data[1].data).to be 55
      expect(test_data.last).to be == '|'
    end

    it 'sends the error if the dependency has an error' do
      error = StandardError.new('Error!')
      trackable = described_class.enumerable([5, 4]).depend_on(
        described_class.value(55).concat(described_class.error(error))
      )

      attach_test_trackers(trackable)

      expect(test_data.size).to be 1
      expect(test_data.last).to be == error
    end
  end
end
