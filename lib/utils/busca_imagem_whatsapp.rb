# frozen_string_literal: true

require 'net/http'
require 'json'

module Utils
  module BuscaImagemWhatsapp
    class << self
      def buscar(numero_whatsapp)
        return nil if numero_whatsapp.blank?

        url = ENV['N8N_WEBHOOK_BUSCA_IMAGEM_WHATSAPP']
        return nil if url.blank?

        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')

        request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        request.body = { whatsappNumber: numero_whatsapp }.to_json

        response = http.request(request)
        data = JSON.parse(response.body)

        data['imageUrl']
      rescue StandardError => e
        Rails.logger.error "Erro ao buscar imagem do WhatsApp via N8N: #{e.message}"
        nil
      end
    end
  end
end
