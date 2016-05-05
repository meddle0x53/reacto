context Reacto::SharedTrackable do
  subject do
    described_class.interval(0.3).take(10)
  end

  context '#track' do
    it 'does not activate the behaviour' do
      attach_test_trackers(subject)

      sleep 1
      expect(test_data).to be_empty
    end
  end

  context '#activate!' do
    it 'activates the Trackable behavior, all the assigned trackers receive ' \
      'the same notifications' do
      attach_test_trackers(subject)

      additional_test_data = []
      subject.on(value: ->(v) { additional_test_data << v })
      subject.activate!

      sleep 1
      expect(test_data).to be == (0..2).to_a
      expect(additional_test_data).to be == (0..2).to_a

      yet_another_test_data = []
      subject.on(value: ->(v) { yet_another_test_data << v })

      sleep 1

      expect(test_data).to be == (0..5).to_a
      expect(additional_test_data).to be == (0..5).to_a
      expect(yet_another_test_data).to be == (3..5).to_a
    end
  end
end
