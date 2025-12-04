# ao receber uma chamada get com o apoiador_id
# deve-se retornar as visitas marcadas para o lider que é o apoiador_id
# deve-se retornar um json com as visitas
class Api::Chatbot::VisitasController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_apoiador!

  def index
    apoiador_id = params[:apoiador_id]

    unless apoiador_id.present?
      return render json: { error: "apoiador_id é obrigatório" }, status: :bad_request
    end

    visitas = Visita.where(lider_id: apoiador_id).order(created_at: :asc)

    visitas_json = visitas.map do |visita|
      {
        id: visita.id,
        lider_id: visita.lider_id,
        lider_name: visita.lider.name,
        data: visita.created_at,
        relato: visita.relato,
        status: visita.status
      }
    end

    render json: { visitas: visitas_json }, status: :ok
  end
end