require "net/http"
require "uri"
require "json"

class SendWhatsappJob < ApplicationJob
  queue_as :default

  # Tenta reenviar até 5 vezes se der erro de conexão ou erro no servidor da Evolution
  retry_on Net::OpenTimeout, Net::ReadTimeout, SocketError, wait: :exponentially_longer, attempts: 5

  # args: hash com { whatsapp:, mensagem:, image_url: (opcional) }
  def perform(whatsapp:, mensagem:, image_url: nil)
    Rails.logger.info "SendWhatsappJob: Iniciando envio para #{whatsapp}. Image URL: #{image_url.inspect}"

    # Normaliza o número usando a lib Utils::NormalizaNumeroWhatsapp
    numero = Utils::NormalizaNumeroWhatsapp.format(whatsapp)

    if numero.blank?
      Rails.logger.error "Número de WhatsApp inválido: #{whatsapp}"
      return
    end

    if image_url.present?
      enviar_imagem(numero, mensagem, image_url)
    else
      enviar_texto(numero, mensagem)
    end
  end

  private

  def enviar_texto(numero, texto)
    instance_name = ENV.fetch("EVOLUTION_INSTANCE_NAME", "ivone")
    body = {
      number: numero,
      text: texto
    }
    fazer_requisicao("/message/sendText/#{instance_name}", body)
  end

  def enviar_imagem(numero, caption, image_url)
    instance_name = ENV.fetch("EVOLUTION_INSTANCE_NAME", "ivone")
    mimetype = image_url.to_s.downcase.end_with?(".png") ? "image/png" : "image/jpeg"
    body = {
      number: numero,
      mediatype: "image",
      mimetype: mimetype,
      caption: caption,
      media: image_url
    }
    fazer_requisicao("/message/sendMedia/#{instance_name}", body)
  end

  def fazer_requisicao(endpoint, body)
    base_url = ENV.fetch("EVOLUTION_HOST")
    api_key = ENV.fetch("EVOLUTION_AUTHENTICATION_API_KEY")

    # Remove barra final do host se tiver e inicial do endpoint se tiver para evitar //
    url = URI.join(base_url, endpoint)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["apikey"] = api_key
    request.body = body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      # Levanta erro para o Active Job capturar e tentar novamente (retry_on)
      raise "Erro na Evolution API: #{response.code} - #{response.body}"
    end

    Rails.logger.info "Mensagem enviada para #{body[:number]} com sucesso."
  end
end
