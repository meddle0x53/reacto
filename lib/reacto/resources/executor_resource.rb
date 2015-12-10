module Reacto
  module Resources
    class ExecutorResource
      def initialize(executor)
        @executor = executor
      end
      def cleanup
        @executor.shutdown
        @executor = nil
      end
    end
  end
end
