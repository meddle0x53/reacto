require 'spec_helper'

context Reacto::Trackable do
  context '.value' do
    it 'emits only the passed value and then closes' do
      trackable = described_class.value(5)
      subscription = attach_test_trackers(trackable)

      expect(test_data).to be == [5, '|']
    end
  end

  context '.enumerable' do
    it 'emits the whole enumerable one-by-one and then closes' do
      trackable = described_class.enumerable([1, 3, 5, 6, 7, 8])
      subscription = attach_test_trackers(trackable)

      expect(test_data).to be == [1, 3, 5, 6, 7, 8, '|']
    end

    it 'on error it emits all til the error and the error' do
      class PositiveArray
        include Enumerable

        def error
          @error ||= StandardError.new('Bad.')
        end

        def initialize(*members)
          @members = members
        end

        def each(&block)
          @members.each do |member|
            raise error if member < 0
            block.call(member)
          end
        end
      end

      enumerable = PositiveArray.new(2, 3, -4, 3, 6)
      trackable = described_class.enumerable(enumerable)
      subscription = attach_test_trackers(trackable)

      expect(test_data).to be == [2, 3, enumerable.error]

    end
  end

  context '.combine' do
    it 'combines the notifications of Trackables with different number of ' \
      'notifications using the passed combinator' do
      trackable1 = described_class.interval(0.3).take(4)
      trackable2 = described_class.interval(0.7, ('a'..'b').each)
      trackable3 = described_class.interval(0.5, ('A'..'C').each)

      trackable = described_class.combine(
        trackable1, trackable2, trackable3
      ) do |v1, v2, v3|
        "#{v1} : #{v2} : #{v3}"
      end

      subscription = attach_test_trackers(trackable)
      trackable.await(subscription)

      expect(test_data).to be == [
        '1 : a : A', '2 : a : A', '2 : a : B', '3 : a : B',
        '3 : b : B', '3 : b : C', '|'
      ]
    end
  end

  context '.combine_last' do
    it 'combines the notifications of Trackables based on their ' \
      'sequence number - the first notification of the sources, then ' \
      'the next ones and in the end closes if any of the sources closes' do
      trackable1 = described_class.interval(0.3).take(4)
      trackable2 = described_class.interval(0.7, ('a'..'b').each)
      trackable3 = described_class.interval(0.5, ('A'..'C').each)

      trackable = described_class.combine_last(
        trackable1, trackable2, trackable3
      ) do |v1, v2, v3|
        "#{v1} : #{v2} : #{v3}"
      end

      subscription = attach_test_trackers(trackable)
      trackable.await(subscription)

      expect(test_data).to be == [
        '1 : a : A', '3 : b : B', '|'
      ]
    end
  end
end
