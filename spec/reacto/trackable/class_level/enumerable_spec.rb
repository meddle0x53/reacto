require 'spec_helper'

context Reacto::Trackable do
  context '.enumerable' do
    it 'emits the whole enumerable one-by-one and then closes' do
      trackable = described_class.enumerable([1, 3, 5, 6, 7, 8])
      attach_test_trackers(trackable)

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
      attach_test_trackers(trackable)

      expect(test_data).to be == [2, 3, enumerable.error]
    end
  end
end
