module Reacto
  module Operations
    class Prepend
      attr_reader :enumerable

      def initialize(enumerable)
        @enumerable = enumerable
      end

      def call(tracker)
        enumerable.each { |value| tracker.on_value(value) }
        tracker
      end
    end
  end
end
