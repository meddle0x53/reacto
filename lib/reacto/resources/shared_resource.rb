module Reacto
  module Resources
    class SharedResource
      def initialize(trackable)
        @trackable = trackable
      end

      def cleanup
        @trackable.off
        @trackable = nil
      end
    end
  end
end
