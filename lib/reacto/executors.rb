require 'concurrent/executor/immediate_executor'

module Reacto
  module Executors
    module_function

    def immediate
      Concurrent::ImmediateExecutor.new
    end

    def io
      Concurrent::CachedThreadPool.new
    end

  end
end
