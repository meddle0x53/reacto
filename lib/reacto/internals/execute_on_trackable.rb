module Reacto
  module Internals
    class ExecuteOnTrackable < Reacto::Trackable
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
