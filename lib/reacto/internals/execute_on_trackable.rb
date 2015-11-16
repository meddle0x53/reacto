require 'reacto/trackable'

module Reacto
  module Internals
    class ExecuteOnTrackable < Trackable
      def initialize(behavior, executor)
        super(behavior)

        @executor = executor
      end

      protected

      def do_track(subscription)
        @executor.post(subscription, &@action)
      end
    end
  end
end
