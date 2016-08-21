require 'concurrent'

module Reacto
  module Subscriptions
    class BufferedSubscription < SimpleSubscription
      include Subscription

      attr_accessor :buffer, :last_error

      def initialize(parent)
        @parent = parent
        @closed = false
        @active = false

        @buffer = Hash.new(NO_VALUE)
        @current_index = Concurrent::AtomicFixnum.new(0)
        @last_error = nil

        open = -> () do
          @active = true
          @parent.on_open
        end

        value = -> (v) do
          @buffer[@current_index.value] = v
          @current_index.increment

          @parent.on_value(v)
        end

        error = -> (e) do
          @last_error = e
          @parent.on_error(e)
        end

        close = -> () do
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
