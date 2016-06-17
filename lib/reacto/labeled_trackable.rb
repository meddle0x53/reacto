require 'reacto/trackable'

module Reacto
  class LabeledTrackable < Trackable
    attr_reader :label

    def initialize(label, executor = nil, behaviour = NO_ACTION, &block)
      super(behaviour, executor, &block)

      @label = label
    end

    protected

    def create_lifted(&block)
      self.class.new(label, @executor, nil, &block)
    end
  end
end
