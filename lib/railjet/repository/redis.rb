require_relative "generic"

module Railjet
  module Repository
    class Redis < Generic
      self.type = :redis

      def get(key)
        redis.get(key)
      end

      def set(key, val)
        redis.set(key, val)
      end

      def exists?(key)
        redis.exists(key)
      end

      def transaction(&block)
        redis.multi(&block)
      end

      def pipeline(&block)
        redis.pipelined(&block)
      end
    end
  end
end