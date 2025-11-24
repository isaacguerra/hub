module Mobile
  class MunicipiosController < BaseController
    before_action :authorize_admin!
    before_action :set_municipio, only: %i[show edit update destroy]

    def index
      @municipios = Municipio.order(:name)
    end

    def show
      @regioes = @municipio.regioes.order(:name)
    end

    def new
      @municipio = Municipio.new
    end

    def create
      @municipio = Municipio.new(municipio_params)
      if @municipio.save
        redirect_to mobile_municipios_path, notice: "Município criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @municipio.update(municipio_params)
        redirect_to mobile_municipios_path, notice: "Município atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @municipio.destroy
      redirect_to mobile_municipios_path, notice: "Município excluído com sucesso."
    end

    private

    def set_municipio
      @municipio = Municipio.find(params[:id])
    end

    def municipio_params
      params.require(:municipio).permit(:name)
    end

    def authorize_admin!
      unless Current.apoiador.candidato? || Current.apoiador.coordenador_geral?
        redirect_to mobile_dashboard_path, alert: "Acesso não autorizado."
      end
    end
  end
end
