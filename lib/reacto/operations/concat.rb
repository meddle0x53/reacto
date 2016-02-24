require 'reacto/subscriptions/operation_subscription'

module Reacto
  module Operations
    class Concat
      # TODO Continue on error flag!
      def initialize(trackable)
        @trackable = trackable
      end

      def call(tracker)
        Subscriptions::OperationSubscription.new(
          tracker,
          close: -> () { @trackable.send(:do_track, tracker) },
          error: -> (e) { 
            tracker.on_error(e)
            @trackable.send(:do_track, tracker)
          }
        )
      end
    end
  end
end
