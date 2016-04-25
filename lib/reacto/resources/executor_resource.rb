module Reacto
  module Resources
    class ExecutorResource
      def initialize(executor, threads: [])
        @executor = executor
        @threads = threads
      end
      def cleanup
        @executor.shutdown unless @executor.nil?
        @executor = nil

        @threads.each do |thread|
          Thread.kill(thread)
        end
        @threads = []
      end
    end
  end
end
