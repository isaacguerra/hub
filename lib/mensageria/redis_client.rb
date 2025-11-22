# frozen_string_literal: true

module Mensageria
  module RedisClient
    class << self
      def connection
        @connection ||= connect
      end

      def publish(channel, message)
        connection.publish(channel, message)
      end

      def close
        return unless @connection

        @connection.close
        @connection = nil
      end

      private

      def connect
        redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')
        Redis.new(url: redis_url)
      rescue Redis::CannotConnectError => e
        Rails.logger.error "Erro ao conectar ao Redis: #{e.message}"
        raise
      end
    end
  end
end
