module Mobile
  class BairrosController < BaseController
    before_action :authorize_admin!
    before_action :set_context
    before_action :set_bairro, only: %i[edit update destroy]

    def new
      @bairro = @regiao.bairros.build
    end

    def create
      @bairro = @regiao.bairros.build(bairro_params)
      if @bairro.save
        redirect_to mobile_municipio_regiao_path(@municipio, @regiao), notice: "Bairro criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @bairro.update(bairro_params)
        redirect_to mobile_municipio_regiao_path(@municipio, @regiao), notice: "Bairro atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @bairro.destroy
      redirect_to mobile_municipio_regiao_path(@municipio, @regiao), notice: "Bairro excluído com sucesso."
    end

    private

    def set_context
      @municipio = Municipio.find(params[:municipio_id])
      @regiao = @municipio.regioes.find(params[:regiao_id])
    end

    def set_bairro
      @bairro = @regiao.bairros.find(params[:id])
    end

    def bairro_params
      params.require(:bairro).permit(:name)
    end

    def authorize_admin!
      unless Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        redirect_to mobile_dashboard_path, alert: "Acesso não autorizado."
      end
    end
  end
end
