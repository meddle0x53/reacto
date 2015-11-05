require 'spec_helper'

describe Reacto::Trackable do

  context 'subscribtion bahaviour' do

  end

  describe '#on' do
    it 'returns a Reacto::Subscription' do
      actual = described_class.new(Reacto::NO_ACTION).on

      expect(actual).to_not be(nil)
      expect(actual).to be_kind_of(Reacto::Subscription)
    end
  end

end
