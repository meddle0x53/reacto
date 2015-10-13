
module Reacto
  class Stream

    def on(type = :value, listener)
      @listeners ||= {}
      @listeners[type] ||= []

      @listeners[type] << listener
    end

  end
end
