module Mobile
  class VisitasController < BaseController
    before_action :set_visita, only: %i[edit update destroy]
    before_action :authorize_create, only: %i[new create]
    before_action :authorize_manage, only: %i[edit update destroy]
    before_action :load_apoiadores, only: %i[new create edit update]

    def index
      @visitas = if Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        Visita.all
      elsif Current.apoiador.coordenador_municipal?
        Visita.joins(:apoiador).where(apoiadores: { municipio_id: Current.apoiador.municipio_id })
      elsif Current.apoiador.coordenador_regional?
        Visita.joins(:apoiador).where(apoiadores: { regiao_id: Current.apoiador.regiao_id })
      elsif Current.apoiador.coordenador_bairro?
        Visita.joins(:apoiador).where(apoiadores: { bairro_id: Current.apoiador.bairro_id })
      elsif Current.apoiador.lider?
        Visita.where(lider_id: Current.apoiador.id)
      else
        Visita.where(apoiador_id: Current.apoiador.id)
      end.includes(:lider, :apoiador).order(created_at: :desc)
    end

    def new
      @visita = Visita.new
    end

    def create
      @visita = Visita.new(visita_params)
      @visita.lider = Current.apoiador # Quem registra a visita é o líder/usuário atual

      if @visita.save
        redirect_to mobile_visitas_path, notice: "Visita registrada com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @visita.update(visita_params)
        redirect_to mobile_visitas_path, notice: "Visita atualizada com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @visita.destroy
      redirect_to mobile_visitas_path, notice: "Visita excluída com sucesso."
    end

    private

    def set_visita
      @visita = Visita.find(params[:id])
    end

    def load_apoiadores
      @apoiadores = Apoiador.order(:nome)
    end

    def visita_params
      params.require(:visita).permit(:apoiador_id, :status, :relato)
    end

    def authorize_create
      unless Current.apoiador.e_autorizado?(:criar_visita)
        redirect_to mobile_visitas_path, alert: "Você não tem permissão para registrar visitas."
      end
    end

    def authorize_manage
      unless Current.apoiador.e_autorizado?(:gerenciar_visita, @visita)
        redirect_to mobile_visitas_path, alert: "Você não tem permissão para gerenciar esta visita."
      end
    end
  end
end
