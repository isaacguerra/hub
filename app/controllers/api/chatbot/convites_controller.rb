# ao receber um chamada post com paramas lider_id, whatsapp e nome
# deve-se criar um novo convite para o lider_id com os dados recebidos
# caso o whatsapp ja exista na base, retorna erro 409
class Api::Chatbot::ConvitesController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_apoiador!

  def create
    lider_id = params[:lider_id]
    whatsapp_param = params[:whatsapp]
    nome_param = params[:nome]

    unless lider_id.present? && whatsapp_param.present? && nome_param.present?
      return render json: { error: "Líder ID, Whatsapp e Nome são obrigatórios" }, status: :bad_request
    end

    # Formata numero (apenas numeros)
    whatsapp_formatted = Utils::NormalizaNumeroWhatsapp.format_chatbot_number(whatsapp_param)

    # Verifica se o whatsapp já existe
    if Apoiador.exists?(whatsapp: whatsapp_formatted)
      return render json: { error: "Whatsapp já cadastrado" }, status: :conflict
    end

    convite = Convite.new(
      enviado_por_id: lider_id,
      whatsapp: whatsapp_formatted,
      nome: nome_param,
      status: "pendente"
    )

    if convite.save
      render json: { message: "Convite criado com sucesso", convite_id: convite.id }, status: :created
    else
      render json: { error: "Erro ao criar convite", details: convite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    lider_id = params[:lider_id]

    unless lider_id.present?
      return render json: { error: "Líder ID é obrigatório" }, status: :bad_request
    end

    convites = Convite.where(enviado_por_id: lider_id).order(created_at: :desc)

    convites_json = convites.map do |convite|
      {
        id: convite.id,
        lider_id: convite.enviado_por_id,
        whatsapp: convite.whatsapp,
        nome: convite.nome,
        status: convite.status,
        criado_em: convite.created_at
      }
    end

    render json: { convites: convites_json }, status: :ok
  end
end