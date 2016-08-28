module Reacto
  NOTHING = {}
  NO_ACTION = -> (*_args) {}
  IDENTITY_ACTION = -> (arg) { arg }
  DEFAULT_ON_ERROR = -> (e) { raise e }
  ID = -> (v) { v }
  NO_VALUE = {}
  TRUE_PREDICATE = -> (_val) { true }
  FALSE_PREDICATE = -> (_val) { false }
end
