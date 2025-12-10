module Mobile
  class ComunicadosController < BaseController
    before_action :set_comunicado, only: %i[show edit update destroy]
    before_action :authorize_create, only: %i[new create]
    before_action :authorize_manage, only: %i[edit update destroy]

    def index
      @comunicados = Comunicado.all.order(created_at: :desc)
    end

    def show
      @engajados = @comunicado.apoiadores
                              .includes(:municipio, :bairro)
                              .where(comunicado_apoiadores: { engajado: true })
                              .order(:nome)
    end

    def new
      @comunicado = Comunicado.new
    end

    def create
      @comunicado = Comunicado.new(comunicado_params)
      @comunicado.lider = Current.apoiador # Assume que quem cria é o "lider" do comunicado, ou ajustamos conforme modelo

      if @comunicado.save
        redirect_to mobile_comunicados_path, notice: "Comunicado criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @comunicado.update(comunicado_params)
        redirect_to mobile_comunicados_path, notice: "Comunicado atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @comunicado.destroy
      redirect_to mobile_comunicados_path, notice: "Comunicado excluído com sucesso."
    end

    private

    def set_comunicado
      @comunicado = Comunicado.find(params[:id])
    end

    def comunicado_params
      params.require(:comunicado).permit(:titulo, :mensagem, :data)
    end

    def authorize_create
      unless Current.apoiador.e_autorizado?(:criar_comunicado)
        redirect_to mobile_comunicados_path, alert: "Você não tem permissão para criar comunicados."
      end
    end

    def authorize_manage
      unless Current.apoiador.e_autorizado?(:gerenciar_comunicado, @comunicado)
        redirect_to mobile_comunicados_path, alert: "Você não tem permissão para gerenciar este comunicado."
      end
    end
  end
end
