module Api
  class PaineisController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_apoiador!

    def show
      whatsapp_param = params[:whatsapp]
      real_ip = params[:real_ip]

      unless whatsapp_param.present?
        return render json: { error: "Whatsapp é obrigatório" }, status: :bad_request
      end

      # Formata numero (apenas numeros)
      whatsapp_formatted = whatsapp_param.gsub(/\D/, "")

      # Tenta encontrar o apoiador
      apoiador = Apoiador.find_by(whatsapp: whatsapp_formatted)

      unless apoiador
        return render json: { error: "Apoiador não encontrado" }, status: :not_found
      end

      base_url = ENV["BASE_URL"] || "http://app.ivonechagas.com.br"

      # Cria o Linkpainel
      # A URL de destino é configurada para o painel
      link = Linkpainel.create(
        apoiador: apoiador,
        url: "#{base_url}/painel",
        real_ip: real_ip,
        status: "ativo"
      )

      if link.persisted?
        # TODO: Implementar notificação se necessário
        # notifica_link_url_slug(link.url_completa, apoiador.name, whatsapp_formatted)

        render json: { url: link.url_completa }, status: :ok
      else
        render json: { error: "Erro ao gerar link", details: link.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
