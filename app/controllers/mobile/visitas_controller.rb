module Mobile
  class VisitasController < BaseController
    before_action :set_visita, only: %i[show edit update destroy]
    before_action :authorize_create, only: %i[new create]
    before_action :authorize_manage, only: %i[edit update destroy]
    before_action :load_apoiadores, only: %i[new create edit update]

    def index
      @visitas = Visita.where(apoiador_id: Current.apoiador.id)
                       .or(Visita.where(lider_id: Current.apoiador.id))
                       .includes(:lider, :apoiador)
                       .order(created_at: :desc)
    end

    def show
    end

    def new
      @visita = Visita.new
    end

    def create
      @visita = Visita.new(visita_params)
      @visita.lider = Current.apoiador # Quem registra a visita é o líder/usuário atual
      @visita.status = "pendente"

      if @visita.save
        redirect_to mobile_visitas_path, notice: "Visita registrada com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      # Se estiver editando o relato, marca como concluída
      if visita_params[:relato].present?
        @visita.status = "concluida"
      end

      if @visita.update(visita_params)
        redirect_to mobile_visita_path(@visita), notice: "Visita atualizada com sucesso."
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
      @apoiadores = Current.apoiador.liderados.order(:nome)
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
