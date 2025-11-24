module Api
  module Mobile
    class AuthsController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_apoiador!, only: [ :login ]

      def login
        whatsapp = params[:whatsapp] || params[:whatsappNumber]

        unless whatsapp.present?
          render json: { error: "WhatsApp é obrigatório" }, status: :bad_request
          return
        end

        normalized_whatsapp = Utils::NormalizaNumeroWhatsapp.format_chatbot_number(whatsapp)
        apoiador = Apoiador.find_by(whatsapp: normalized_whatsapp)

        if apoiador
          apoiador.gerar_codigo_acesso!
          Mensageria::Notificacoes::Autenticacao.enviar_link_magico(apoiador)
          render json: { message: "Link enviado com sucesso" }, status: :ok
        else
          render json: { error: "Número não encontrado" }, status: :not_found
        end
      end
    end
  end
end
