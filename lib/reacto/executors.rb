require 'concurrent/executor/immediate_executor'

module Reacto
  module Executors
    module_function

    def immediate
      Concurrent::ImmediateExecutor.new
    end

  end
end
