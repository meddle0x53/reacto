context Reacto::Trackable do
  context '#reject' do
    it 'notifies with values not passing the filter block' do
      trackable = source.reject(&:even?)
      trackable.on(value: test_on_value)

      expect(test_data.size).to be(1)
      expect(test_data.first).to be(5)
    end

    it 'does not notify with values passing the filter block' do
      trackable = source.reject(&:odd?)

      trackable.on(value: test_on_value)

      expect(test_data.size).to be(0)
    end
  end
end
