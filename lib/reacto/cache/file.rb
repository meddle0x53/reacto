require 'yaml'
require 'reacto/cache/memory'

module Reacto
  module Cache
    class File
      attr_reader :location, :ttl
      attr_reader :data

      def initialize(location: nil, ttl: 60)
        @location = location
        @ttl = ttl

        if @location.nil?
          fail(
            ArgumentError, 'File location is mandatory while using file cache!'
          )
        end
      end

      def ready?
        return data.ready? unless data.nil?

        fresh?
      end

      def each
        return unless ready?
        deserialize

        data.each do |value|
          yield value
        end
      end

      def error?
        return false unless ready?
        deserialize

        data.error?
      end

      def closed?
        return false unless ready?
        deserialize

        data.closed?
      end

      def error
        return false unless ready?
        deserialize

        data.error
      end

      def on_value(value)
        init_data

        data.on_value(value)
      end

      def on_error(error)
        init_data

        data.on_error(error)
        serialize
      end

      def on_close
        init_data

        data.on_close
        serialize
      end

      private

      def fresh?
        ::File.file?(location) && (Time.now - ::File.mtime(location)) <= ttl
      end

      def init_data
        @data ||= Memory.new
      end

      def deserialize
        return unless fresh?

        @data ||= YAML.load(::File.read(location))
      end

      def serialize
        return if data.nil?

        ::File.open(location, 'w') do |f|
          f.write(YAML.dump(data))
        end
      end
    end
  end
end
