module Reacto
  module Subscriptions
    module Subscription
      def subscribed?
        raise NotImplementedError.new('Abstract method!')
      end

      def unsubscribe
        raise NotImplementedError.new('Abstract method!')
      end
    end
  end
end
