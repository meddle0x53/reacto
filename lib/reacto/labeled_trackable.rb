require 'reacto/trackable'

module Reacto
  class LabeledTrackable < Trackable
    attr_reader :label

    def initialize(label, executor = nil, behaviour = NO_ACTION, &block)
      super(behaviour, executor, &block)

      @label = label
    end
  end
end
