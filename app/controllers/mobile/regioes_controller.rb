module Mobile
  class RegioesController < BaseController
    before_action :authorize_admin!
    before_action :set_municipio
    before_action :set_regiao, only: %i[show edit update destroy]

    def show
      @bairros = @regiao.bairros.order(:name)
    end

    def new
      @regiao = @municipio.regioes.build
    end

    def create
      @regiao = @municipio.regioes.build(regiao_params)
      if @regiao.save
        redirect_to mobile_municipio_path(@municipio), notice: "Região criada com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @regiao.update(regiao_params)
        redirect_to mobile_municipio_path(@municipio), notice: "Região atualizada com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @regiao.destroy
      redirect_to mobile_municipio_path(@municipio), notice: "Região excluída com sucesso."
    end

    private

    def set_municipio
      @municipio = Municipio.find(params[:municipio_id])
    end

    def set_regiao
      @regiao = @municipio.regioes.find(params[:id])
    end

    def regiao_params
      params.require(:regiao).permit(:name, :coordenador_id)
    end

    def authorize_admin!
      unless Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        redirect_to mobile_dashboard_path, alert: "Acesso não autorizado."
      end
    end
  end
end
