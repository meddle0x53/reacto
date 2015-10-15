module Reacto
  class NotificationTracker
    attr_reader :actions

    def initialize(actions)
      @actions = actions
    end

    def on(action_type, value: nil)
    end

  end
end

