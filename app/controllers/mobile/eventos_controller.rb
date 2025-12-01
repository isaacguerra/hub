module Mobile
  class EventosController < BaseController
    before_action :set_evento, only: %i[show edit update destroy]
    before_action :authorize_create, only: %i[new create]
    before_action :authorize_manage, only: %i[edit update destroy]

    def index
      @eventos = Evento.all.order(data: :desc)
    end

    def show
      @participantes = @evento.apoiadores.includes(:municipio, :bairro).order(:nome)
    end

    def new
      @evento = Evento.new
    end

    def create
      @evento = Evento.new(evento_params)
      @evento.coordenador = Current.apoiador # Assume que quem cria é o coordenador do evento

      if @evento.save
        redirect_to mobile_eventos_path, notice: "Evento criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @evento.update(evento_params)
        redirect_to mobile_eventos_path, notice: "Evento atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @evento.destroy
      redirect_to mobile_eventos_path, notice: "Evento excluído com sucesso."
    end

    private

    def set_evento
      @evento = Evento.find(params[:id])
    end

    def evento_params
      params.require(:evento).permit(
        :titulo, :data, :local, :descricao,
        :link_whatsapp, :link_instagram, :link_facebook, :link_tiktok,
        :filtro_funcao_id, :filtro_municipio_id, :filtro_regiao_id, :filtro_bairro_id
      )
    end

    def authorize_create
      unless Current.apoiador.pode_coordenar? || Current.apoiador.lider?
        redirect_to mobile_eventos_path, alert: "Você não tem permissão para criar eventos."
      end
    end

    def authorize_manage
      can_manage = Current.apoiador.candidato? ||
                   Current.apoiador.coordenador_geral? ||
                   @evento.coordenador_id == Current.apoiador.id

      unless can_manage
        redirect_to mobile_eventos_path, alert: "Você não tem permissão para gerenciar este evento."
      end
    end
  end
end
