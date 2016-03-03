module Reacto
  module Subscriptions
    class BufferedSubscription < SimpleSubscription
      include Subscription

      attr_accessor :current_index, :buffer, :last_error

      def initialize(parent)
        @parent = parent
        @closed = false
        @active = false

        @buffer = Hash.new(NO_VALUE)
        @current_index = 0
        @last_error = nil

        open = lambda do
          @active = true
          @parent.on_open
        end

        value = lambda do |v|
          @buffer[@current_index] = v
          @current_index += 1

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

