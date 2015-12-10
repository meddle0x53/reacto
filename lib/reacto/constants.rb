module Reacto
  NOTHING = {}
  NO_ACTION = -> (*args) {}
  DEFAULT_ON_ERROR = -> (e) { raise e }
  ID = -> (v) { v }
end
