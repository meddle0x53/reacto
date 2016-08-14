module Reacto
  NOTHING = {}
  NO_ACTION = -> (*args) {}
  IDENTITY_ACTION = -> (arg) { arg }
  DEFAULT_ON_ERROR = -> (e) { raise e }
  ID = -> (v) { v }
  NO_VALUE = {}
end
