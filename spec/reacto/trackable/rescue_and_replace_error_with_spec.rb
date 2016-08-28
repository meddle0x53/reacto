context Reacto::Trackable do
  context '#rescue_and_replace_error_with' do
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
      'given Reacto::Trackable instance' do
      trackable = test_source.rescue_and_replace_error_with(
        Reacto::Trackable.enumerable(%w(so that's a goodbye then))
      )
      attach_test_trackers(trackable)

      expect(test_data).to eq(%w(Hi! so that's a goodbye then |))
    end
  end
end
