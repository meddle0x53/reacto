module Reacto
  module Cache
    class Memory
      def initialize(_ = nil)
        @values = []
        @closed = false
      end

      def each
        @values.each do |value|
          yield value
        end
      end

      def ready?
        error? || closed?
      end

      def error?
        @error != nil
      end

      def closed?
        @closed
      end

      def error
        @error
      end

      def on_value(value)
        @values << value
      end

      def on_error(error)
        @error = error
      end

      def on_close
        @closed = true
      end
    end
  end
end
