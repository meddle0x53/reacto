context Reacto::Trackable do
  context '#rescue_and_replace_error' do
    let(:test_error) { StandardError.new('Bang!') }

    subject(:test_source) do
      described_class.make do |tracker|
        tracker.on_value('Hi!')

        tracker.on_error(test_error)

        tracker.on_value('Bye.')
        tracker.on_close
      end
    end

    it 'replaces the emitted error with the a new sequence emitted by the ' \
      'Reacto::Trackable instance, returned by the passed block' do

      trackable = test_source.rescue_and_replace_error do |error|
        if error.message == 'Bang!'
          Reacto::Trackable.enumerable(%w(so that's a goodbye then))
        else
          Reacto::Trackable.error(error)
        end
      end

      attach_test_trackers(trackable)

      expect(test_data).to eq(%w(Hi! so that's a goodbye then |))
    end

    it 'replaces the emitted error with the a new sequence emitted by the ' \
      'Reacto::Trackable instance, returned by the passed block. Error case' do

      trackable = test_source.rescue_and_replace_error do |error|
        if error.message == 'Gang!'
          Reacto::Trackable.enumerable(%w(so that's a goodbye then))
        else
          Reacto::Trackable.error(error)
        end
      end

      attach_test_trackers(trackable)

      expect(test_data).to eq(['Hi!', test_error])
    end
  end
end
