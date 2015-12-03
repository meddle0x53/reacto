require 'concurrent/executor/immediate_executor'
require 'concurrent/executor/cached_thread_pool'
require 'concurrent/executor/fixed_thread_pool'

module Reacto
  module Executors
    class CurrentExecutor
      def post

      end
    end

    module_function

    def immediate
      Concurrent::ImmediateExecutor.new
    end

    def current
      Concurrent::ImmediateExecutor.new
    end

    def io
      Concurrent::CachedThreadPool.new
    end

    def tasks
      Concurrent::FixedThreadPool.new(4) # Number of cores here?
    end
  end
end
