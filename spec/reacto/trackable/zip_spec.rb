require 'spec_helper'

context Reacto::Trackable do
  context '.zip' do
    it 'combines the first notifications of the source Trackable instances, ' \
      'then the second ones, then the third ones and etc. until some of ' \
      'the sources closes' do

      trackable1 = described_class.interval(0.3).drop(1).take(4)
      trackable2 = described_class.interval(0.7, ('a'..'b').each)
      trackable3 = described_class.interval(0.5, ('A'..'C').each)

      trackable = described_class.zip(
        trackable1, trackable2, trackable3
      ) do |v1, v2, v3|
        "#{v1} : #{v2} : #{v3}"
      end

      subscription = attach_test_trackers(trackable)
      trackable.await(subscription)

      expect(test_data).to be == ['1 : a : A', '2 : b : B', '|']
    end
  end
end
