module Reacto
  NO_ACTION = -> (*args) {}
  DEFAULT_ON_ERROR = -> (e) { raise e }

  SINGLE_VALUE_BEHAVIOUR = lambda do |tracker, value|
    tracker.on_value(value)
    tracker.on_close
  end
end
