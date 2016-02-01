module Reacto
  module Subscriptions
    class InnerSubscription < SimpleSubscription
      include Subscription

      attr_accessor :last_value, :last_error

      def initialize(parent)
        @parent = parent
        @closed = false
        @active = false
        @last_value = NO_VALUE
        @last_error = nil

        open = lambda do
          @active = true
          @parent.on_open
        end

        value = lambda do |v|
          @last_value = v
          @parent.on_value(v)
        end

        error = lambda do |e|
          @last_error = e
          @parent.on_error(e)
        end

        close = lambda do
          @closed = true
          @parent.on_close
        end

        super(open: open, value: value, error: error, close: close)
      end

      def active?
        @active
      end

      def closed?
        @closed
      end
    end
  end
end
