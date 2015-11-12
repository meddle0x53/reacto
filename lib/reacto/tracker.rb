require 'reacto/constants'

module Reacto
  class Tracker
    DEFAULT_ON_ERROR = -> (e) { raise e }

    def initialize(
      open: NO_ACTION,
      value: NO_ACTION,
      error: DEFAULT_ON_ERROR,
      close: NO_ACTION
    )
      @open = open
      @value = value
      @error = error
      @close = close
    end

    def on_open
      @open.call
    end

    def on_value(value)
      @value.call(value)
    end

    def on_error(error)
      @error.call(error)
    end

    def on_close
      @close.call
    end
  end
end
