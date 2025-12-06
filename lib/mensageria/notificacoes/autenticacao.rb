# frozen_string_literal: true

module Mensageria
  module Notificacoes
    module Autenticacao
      class << self
        def enviar_codigo(apoiador)
          return unless apoiador.verification_code.present?

          texto = Mensagens::Autenticacao.codigo_acesso(apoiador.verification_code)
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto,
            image_url: imagem_whatsapp
          )
        rescue StandardError => e
          Rails.logger.error "Erro ao enviar código de autenticação para apoiador #{apoiador.id}: #{e.message}"
        end

        def enviar_link_magico(apoiador)
          return unless apoiador.verification_code.present?

          host = ENV.fetch("BASE_URL", "dev.ivonechagas.com.br")
          link = Rails.application.routes.url_helpers.magic_link_url(
            codigo: apoiador.verification_code,
            host: host,
            protocol: Rails.env.production? ? "https" : "http"
          )

          texto = Mensagens::Autenticacao.link_magico(link)
          imagem_whatsapp = Utils::BuscaImagemWhatsapp.buscar(apoiador.whatsapp)

          SendWhatsappJob.perform_later(
            whatsapp: Helpers.format_phone_number(apoiador.whatsapp),
            mensagem: texto,
            image_url: imagem_whatsapp
          )
        rescue StandardError => e
          Rails.logger.error "Erro ao enviar link mágico para apoiador #{apoiador.id}: #{e.message}"
        end
      end
    end
  end
end
