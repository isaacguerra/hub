# ao fazer um chamada get deve-se retornar a lista de eventos ativos
# os eventos ativos são aqueles com data igual a data atual ou seja o dia de hoje
# deve-se retornar os eventos ordenados pela data crescente
class Api::Chatbot::EventosController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_apoiador!

  def index
    eventos_ativos = Evento.where('data >= ?', Date.current).order(data: :asc)

    eventos_json = eventos_ativos.map do |evento|
      {
        id: evento.id,
        titulo: evento.titulo,
        descricao: evento.descricao,
        data: evento.data,
        coordenador: {
          id: evento.coordenador.id,
          name: evento.coordenador.name,
          whatsapp: evento.coordenador.whatsapp
        },
        publico_alvo: evento.descricao_publico_alvo
      }
    end

    render json: { eventos: eventos_json }, status: :ok
  end
end
