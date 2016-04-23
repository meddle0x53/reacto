require 'spec_helper'

context Reacto::Trackable do
  context '#select' do
    it 'doesn\'t notify with values not passing the filter block' do
      trackable = source.select do |v|
        v % 2 == 0
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(0)
    end

    it 'notifies with values passing the filter block' do
      trackable = source.select do |v|
        v % 2 == 1
      end

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data[0]).to be(5)
    end
  end
end
