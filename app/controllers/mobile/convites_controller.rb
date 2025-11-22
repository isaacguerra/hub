module Mobile
  class ConvitesController < BaseController
    before_action :set_convite, only: [ :edit, :update, :destroy ]
    before_action :authorize_create, only: [ :new, :create ]
    before_action :authorize_manage, only: [ :edit, :update, :destroy ]

    def index
      @convites = Convite.all.order(created_at: :desc)
    end

    def new
      @convite = Convite.new
    end

    def create
      @convite = Convite.new(convite_params)
      @convite.enviado_por = Current.apoiador
      @convite.status = "pendente"

      if @convite.save
        redirect_to mobile_convites_path, notice: "Convite enviado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @convite.update(convite_params)
        redirect_to mobile_convites_path, notice: "Convite atualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @convite.destroy
      redirect_to mobile_convites_path, notice: "Convite removido."
    end

    private

    def set_convite
      @convite = Convite.find(params[:id])
    end

    def convite_params
      params.require(:convite).permit(:nome, :whatsapp)
    end

    def authorize_create
      unless Current.apoiador.pode_coordenar?
        redirect_to mobile_convites_path, alert: "Sem permissão para criar convites."
      end
    end

    def authorize_manage
      unless Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        redirect_to mobile_convites_path, alert: "Sem permissão para gerenciar convites."
      end
    end
  end
end
