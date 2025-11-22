# frozen_string_literal: true

module Mensageria
  module Logger
    REDIS_CHANNEL = 'mensageria_logs'

    class << self
      def log_mensagem_apoiador(fila:, image_url:, whatsapp:, mensagem:)
        log_entry = {
          fila: fila,
          imageUrl: image_url,
          whatsapp: whatsapp,
          mensagem: mensagem,
          timestamp: Time.current.iso8601
        }

        RedisClient.publish(REDIS_CHANNEL, log_entry.to_json)
      rescue StandardError => e
        Rails.logger.error "Erro ao registrar log de mensagem: #{e.message}"
      end
    end
  end
end
