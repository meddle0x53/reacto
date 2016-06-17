context Reacto::LabeledTrackable do
  subject do
    described_class.new('label') do |subscriber|
      subscriber.on_value(5)
      subscriber.on_value(15)
      subscriber.on_close
    end
  end

  context '#relabel' do
    it 'creates new LabeledTrackable with label created by the block passed' do
      trackable = subject.relabel { |label| label.gsub('l', 'r') }

      expect(trackable.label).to eq('raber')
    end
  end
end
