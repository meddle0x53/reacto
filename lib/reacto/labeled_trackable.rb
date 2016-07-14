require 'reacto/trackable'

module Reacto
  class LabeledTrackable < Trackable
    attr_reader :label

    def initialize(label, executor = nil, &block)
      super(executor, &block)

      @label = label
    end

    def relabel
      new_label = yield label

      self.class.new(new_label, @executor, &@behaviour)
    end

    protected

    def create_lifted(&block)
      self.class.new(label, @executor, &block)
    end
  end
end
