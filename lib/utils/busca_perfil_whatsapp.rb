# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Utils
  module BuscaPerfilWhatsapp
    class << self
      def buscar(numero_whatsapp)
        return nil if numero_whatsapp.blank?

        # Normaliza o número
        numero = Utils::NormalizaNumeroWhatsapp.format(numero_whatsapp)
        return nil if numero.blank?

        cache_key = "whatsapp_profile:#{numero}"

        Rails.cache.fetch(cache_key, expires_in: 24.hours) do
          realizar_busca_na_api(numero)
        end
      end

      private

      def realizar_busca_na_api(numero)
        base_url = ENV.fetch("EVOLUTION_HOST")
        api_key = ENV.fetch("EVOLUTION_AUTHENTICATION_API_KEY")
        instance_name = ENV.fetch("EVOLUTION_INSTANCE_NAME", "default")

        endpoint = "/chat/fetchProfile/#{instance_name}"

        url = URI.join(base_url, endpoint)

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == "https")

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = "application/json"
        request["apikey"] = api_key
        request.body = { number: numero }.to_json

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          data = JSON.parse(response.body)

          # Mapeia os campos retornados pelo Evolution API
          # O formato exato pode variar, mas geralmente inclui id, name/pushName, picture
          {
            wuid: data["id"] || data["remoteJid"],
            name: data["name"] || data["pushName"] || data["notifyName"],
            picture: data["picture"] || data["profilePictureUrl"] || data["image"] || data["profileImage"]
          }
        else
          Rails.logger.error "Erro ao buscar perfil do WhatsApp via Evolution: #{response.code} - #{response.body}"
          nil
        end
      rescue StandardError => e
        Rails.logger.error "Erro ao buscar perfil do WhatsApp: #{e.message}"
        nil
      end
    end
  end
end
