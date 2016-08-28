require 'concurrent/executor/immediate_executor'
require 'concurrent/executor/cached_thread_pool'
require 'concurrent/executor/fixed_thread_pool'

module Reacto
  module Executors
    module_function

    def immediate
      @immediate ||= Concurrent::ImmediateExecutor.new
    end

    def current
      immediate
    end

    def io
      @io ||= Concurrent::CachedThreadPool.new
    end

    def tasks
      @tasks ||= Concurrent::FixedThreadPool.new(4) # Number of cores here?
    end

    def new_thread
      @new_thread ||= Concurrent::SimpleExecutorService.new
    end
  end
end
