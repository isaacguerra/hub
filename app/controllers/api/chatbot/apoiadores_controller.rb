# ao receber uma chamado post com o parama whatsapp,
# procura o apoiador e retorna os dados do apoiador
# caso contrario retorna erro 404
class Api::Chatbot::ApoiadoresController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_apoiador!

  def create
    whatsapp_param = params[:whatsapp]

    unless whatsapp_param.present?
      return render json: { error: "Whatsapp é obrigatório" }, status: :bad_request
    end

    # Formata numero (apenas numeros)
    whatsapp_formatted = Utils::NormalizaNumeroWhatsapp.format_chatbot_number(whatsapp_param)

    # Tenta encontrar o apoiador
    apoiador = Apoiador.find_by(whatsapp: whatsapp_formatted)

    unless apoiador
      return render json: { error: "Apoiador não encontrado" }, status: :not_found
    end

    render json: {
      id: apoiador.id,
      name: apoiador.name,
      whatsapp: apoiador.whatsapp,
      funcao: apoiador.funcao&.name,
      municipio: apoiador.municipio&.name,
      regiao: apoiador.regiao&.name,
      bairro: apoiador.bairro&.name
    }, status: :ok
  end
end