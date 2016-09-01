context Reacto::Trackable do
  context '#retry' do
    let(:error_checker) do
      array = []
      ->() do
        array << 1

        array.length.odd?
      end
    end

    it 're-runs the whole behaviour of the source trackable if there is ' \
      'an error' do
      trackable = Reacto::Trackable.make do |tracker|
        tracker.on_value('Hi!')

        tracker.on_error(StandardError.new('Bang!')) if error_checker.call

        tracker.on_value('Bye.')
        tracker.on_close
      end.retry

      trackable.on(
        value: test_on_value, error: test_on_error, close: test_on_close
      )

      expect(test_data).to eq(['Hi!', 'Hi!', 'Bye.', '|'])
    end

    it 'emits the error if it persists the retry count times' do
      power_error = StandardError.new('Bang! Bang!')

      trackable = Reacto::Trackable.make do |tracker|
        tracker.on_value('Hi!')

        tracker.on_error(StandardError.new('Bang!')) if error_checker.call
        tracker.on_error(power_error) if error_checker.call

        tracker.on_value('Bye.')
        tracker.on_close
      end.retry(3)

      trackable.on(
        value: test_on_value, error: test_on_error, close: test_on_close
      )

      expect(test_data).to eq(['Hi!', 'Hi!', 'Hi!', 'Hi!', power_error])
    end
  end
end
