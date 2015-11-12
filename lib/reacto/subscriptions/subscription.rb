module Reacto
  module Subscriptions
    module Subscription
      def subscribed?
        !@trackable.nil? && @trackable.subscribed?(@notification_tracker)
      end

      def unsubscribe
        @trackable.off(@notification_tracker)

        @trackable = nil
        @notification_tracker = nil
      end
    end
  end
end
