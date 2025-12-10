module Mobile
  class ConvitesController < BaseController
    before_action :set_convite, only: [ :edit, :update, :destroy ]
    # before_action :authorize_create, only: [ :new, :create ]
    before_action :authorize_manage, only: [ :edit, :update, :destroy ]

    def index
      @convites = scope_convites.order(created_at: :desc)
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

    def scope_convites
      if Current.apoiador.e_autorizado?(:admin)
        Convite.all
      elsif Current.apoiador.coordenador_municipal?
        Convite.joins(:enviado_por).where(apoiadores: { municipio_id: Current.apoiador.municipio_id })
      elsif Current.apoiador.coordenador_regional?
        Convite.joins(:enviado_por).where(apoiadores: { regiao_id: Current.apoiador.regiao_id })
      elsif Current.apoiador.coordenador_bairro?
        Convite.joins(:enviado_por).where(apoiadores: { bairro_id: Current.apoiador.bairro_id })
      elsif Current.apoiador.lider?
        subordinados_ids = Current.apoiador.todos_subordinados(incluir_indiretos: true).map(&:id)
        Convite.where(enviado_por_id: subordinados_ids + [ Current.apoiador.id ])
      else
        Convite.where(enviado_por_id: Current.apoiador.id)
      end
    end

    def set_convite
      @convite = scope_convites.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to mobile_convites_path, alert: "Convite não encontrado ou sem permissão."
    end

    def convite_params
      params.require(:convite).permit(:nome, :whatsapp)
    end

    # def authorize_create
    #   unless Current.apoiador.pode_coordenar?
    #     redirect_to mobile_convites_path, alert: "Sem permissão para criar convites."
    #   end
    # end

    def authorize_manage
      unless Current.apoiador.e_autorizado?(:admin)
        redirect_to mobile_convites_path, alert: "Sem permissão para gerenciar convites."
      end
    end
  end
end
