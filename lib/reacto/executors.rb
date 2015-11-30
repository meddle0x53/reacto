require 'concurrent/executor/immediate_executor'
require 'concurrent/executor/cached_thread_pool'
require 'concurrent/executor/fixed_thread_pool'

module Reacto
  module Executors
    module_function

    def immediate
      Concurrent::ImmediateExecutor.new
    end

    def io
      Concurrent::CachedThreadPool.new
    end

    def tasks
      Concurrent::FixedThreadPool.new(2)
    end
  end
end
