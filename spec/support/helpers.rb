module Helpers
  extend RSpec::SharedContext

  let(:test_data) { [] }
  let(:test_on_value) { -> (v) { test_data << v } }
  let(:test_on_close) { -> () { test_data << '|' } }
  let(:test_on_error) { -> (e) { test_data << e } }

  let(:test_behaviour) do
    lambda do |tracker_subscription|
      tracker_subscription.on_value(5)
      tracker_subscription.on_close
    end
  end

  let(:source) { described_class.new(&test_behaviour) }

  def attach_test_trackers(trackable)
    trackable.on(
      value: test_on_value,
      error: test_on_error,
      close: test_on_close
    )
  end

  def expect_trackable_values(trackable, expected, label: nil)
    expect(trackable.label).to eq(label) if label

    values = []
    trackable.on { |v| values << v }
    expect(values).to eq(expected)
  end
end
