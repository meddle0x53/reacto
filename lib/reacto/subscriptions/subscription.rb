module Reacto
  module Subscriptions
    module Subscription
      def subscribed?
        raise NotImplementedError.new('Abstract method!')
      end

      def unsubscribe
        raise NotImplementedError.new('Abstract method!')
      end

      def add(subscription)
        raise NotImplementedError.new('Abstract method!')
      end

      def add_resource(resource)
        raise NotImplementedError.new('Abstract method!')
      end
    end
  end
end
